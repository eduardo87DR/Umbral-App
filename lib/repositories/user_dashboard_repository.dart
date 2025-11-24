import '../services/api_client.dart';

class UserDashboardRepository {
  final ApiClient api;
  UserDashboardRepository(this.api);

  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    try {
      // 1. Stats del usuario (nivel)
      final userStats = await api.get('/stats/$userId');
      
      // 2. Eventos activos
      final eventsRes = await api.get('/events/count?active=true');
      
      // 3. Guías disponibles
      final guidesRes = await api.get('/guides/count');
      
      // 4. Notificaciones no leídas o solicitudes pendientes
      final notificationsRes = await api.get('/notifications/user/unread-count');

      return {
        'level': userStats['level'] ?? 1,
        'active_events': eventsRes['count'] ?? 0,
        'available_guides': guidesRes['count'] ?? 0,
        'pending_items': notificationsRes['count'] ?? 0,
      };
    } catch (e) {
      print('❌ ERROR - User Dashboard Stats: $e');
      return {
        'level': 1,
        'active_events': 0,
        'available_guides': 0,
        'pending_items': 0,
      };
    }
  }
}