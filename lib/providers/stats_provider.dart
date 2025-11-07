import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/stats_repository.dart';
import '../models/stat.dart';
import 'auth_provider.dart';

final statsRepoProvider = Provider(
  (ref) => StatsRepository(ref.watch(apiClientProvider)),
);

final statsProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<PlayerStats?>>(
  (ref) => StatsNotifier(ref),
);

class StatsNotifier extends StateNotifier<AsyncValue<PlayerStats?>> {
  final Ref ref;

  StatsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final auth = ref.read(authStateProvider).value;
      if (auth == null) {
        state = AsyncValue.error('No hay usuario autenticado', StackTrace.current);
        return;
      }

      final repo = ref.read(statsRepoProvider);
      final stats = await repo.getStats(auth.id);
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
