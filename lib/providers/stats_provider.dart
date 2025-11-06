import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/stats_repository.dart';
import '../models/stat.dart';
import 'auth_provider.dart';

final statsRepoProvider = Provider(
  (ref) => StatsRepository(ref.watch(apiClientProvider)),
);

final statsProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<List<Stat>>>(
  (ref) => StatsNotifier(ref),
);

class StatsNotifier extends StateNotifier<AsyncValue<List<Stat>>> {
  final Ref ref;

  StatsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(statsRepoProvider);
      final list = await repo.getStats();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshStat(String label) async {
  try {
    final stat = await ref.read(statsRepoProvider).getStatByLabel(label);
    if (state is AsyncData<List<Stat>>) {
      final current = (state as AsyncData<List<Stat>>).value;
      final updated = current.map((s) => s.label == stat.label ? stat : s).toList();
      state = AsyncValue.data(updated);
    }
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}

}
