import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/guides_repository.dart';
import '../models/guide.dart';
import 'auth_provider.dart';

final guidesRepoProvider = Provider(
  (ref) => GuidesRepository(ref.watch(apiClientProvider)),
);

final guidesListProvider =
    StateNotifierProvider<GuidesNotifier, AsyncValue<List<Guide>>>(
  (ref) => GuidesNotifier(ref),
);

class GuidesNotifier extends StateNotifier<AsyncValue<List<Guide>>> {
  final Ref ref;

  GuidesNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(guidesRepoProvider);
      final list = await repo.getGuides(limit: 20, offset: 0);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Guide guide) async {
    await ref.read(guidesRepoProvider).createGuide(guide);
    await load();
  }

  Future<void> delete(int id) async {
    await ref.read(guidesRepoProvider).deleteGuide(id);
    await load();
  }

}
