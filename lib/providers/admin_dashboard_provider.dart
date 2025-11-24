import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_dashboard_repository.dart';
import 'auth_provider.dart';

final adminDashboardRepoProvider = Provider<AdminDashboardRepository>(
  (ref) => AdminDashboardRepository(ref.watch(apiClientProvider)),
);

final adminDashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(adminDashboardRepoProvider);
  return await repo.getDashboardStats();
});