import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_dashboard_repository.dart';
import 'auth_provider.dart';

final userDashboardRepoProvider = Provider<UserDashboardRepository>(
  (ref) => UserDashboardRepository(ref.watch(apiClientProvider)),
);

final userDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return {
      'level': 1,
      'active_events': 0,
      'available_guides': 0,
      'pending_items': 0,
    };
  }
  
  final repo = ref.read(userDashboardRepoProvider);
  return await repo.getDashboardStats(user.id);
});