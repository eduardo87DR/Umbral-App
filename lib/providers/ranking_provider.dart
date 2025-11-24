import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ranking_repository.dart';
import '../models/ranking.dart';
import '../providers/auth_provider.dart';


/// Repo
final rankingRepoProvider = Provider(
  (ref) => RankingRepository(ref.watch(apiClientProvider)),
);


/// Provider para el ranking público (/stats/rankings)
final publicRankingProvider = StateNotifierProvider<
    PublicRankingNotifier, AsyncValue<List<RankingEntry>>>(
  (ref) => PublicRankingNotifier(ref),
);

class PublicRankingNotifier
    extends StateNotifier<AsyncValue<List<RankingEntry>>> {
  final Ref ref;

  PublicRankingNotifier(this.ref)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(rankingRepoProvider);
      final data = await repo.getPublicRanking(limit: 10);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}


/// Provider para el ranking admin (/admin/users/rankings)
final adminRankingProvider = StateNotifierProvider<
    AdminRankingNotifier, AsyncValue<List<RankingEntry>>>(
  (ref) => AdminRankingNotifier(ref),
);

class AdminRankingNotifier
    extends StateNotifier<AsyncValue<List<RankingEntry>>> {
  final Ref ref;

  AdminRankingNotifier(this.ref)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final auth = ref.read(authStateProvider).value;

      if (auth == null || auth.role != "admin") {
        state = const AsyncValue.error(
          "Solo un admin puede ver este ranking",
          StackTrace.empty,
        );
        return;
      }

      final repo = ref.read(rankingRepoProvider);
      final data = await repo.getAdminRanking(limit: 10);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
