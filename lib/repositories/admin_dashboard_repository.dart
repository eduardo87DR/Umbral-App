import '../services/api_client.dart';

class AdminDashboardRepository {
  final ApiClient api;
  AdminDashboardRepository(this.api);

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final usersRes = await api.get('/admin/users/count');
      final eventsRes = await api.get('/events/count');
      final guidesRes = await api.get('/guides/count');
      final pendingRes = await api.get('/notifications/admin/requests/count');

      return {
        'users': usersRes['count'] ?? 0,
        'events': eventsRes['count'] ?? 0,
        'guides': guidesRes['count'] ?? 0,
        'pending': pendingRes['count'] ?? 0,
      };
    } catch (e) {
      print('ERROR - Dashboard Stats: $e');
      return {
        'users': 0,
        'events': 0,
        'guides': 0,
        'pending': 0,
      };
    }
  }
}