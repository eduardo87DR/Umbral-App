import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/comments_repository.dart';
import '../models/comment.dart';
import 'auth_provider.dart';

final commentsRepoProvider = Provider(
  (ref) => CommentsRepository(ref.watch(apiClientProvider)),
);

/// provider por guía → para cargar comentarios específicos
final commentsProvider = StateNotifierProvider.family<
    CommentsNotifier,
    AsyncValue<List<Comment>>,
    int>(
  (ref, guideId) => CommentsNotifier(ref, guideId),
);

class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final Ref ref;
  final int guideId;

  CommentsNotifier(this.ref, this.guideId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(commentsRepoProvider);
      final list = await repo.getComments(guideId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String content) async {
    final repo = ref.read(commentsRepoProvider);
    await repo.createComment(guideId, content);
    await load();
  }

  Future<void> edit(int id, String newContent) async {
  try {
    final updated = await ref.read(commentsRepoProvider).updateComment(id, newContent);

    state = state.whenData((list) =>
        list.map((c) => c.id == id ? updated : c).toList());
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}


  Future<void> delete(int id) async {
    final repo = ref.read(commentsRepoProvider);
    await repo.deleteComment(id);
    await load();
  }
}
