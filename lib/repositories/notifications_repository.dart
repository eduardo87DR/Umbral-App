// notifications_repository.dart
import '../services/api_client.dart';
import '../models/app_notification.dart';

// notifications_repository.dart
class NotificationsRepository {
  final ApiClient api;
  NotificationsRepository(this.api);

  /// Obtener notificaciones del usuario actual
  Future<List<AppNotification>> getNotifications() async {
    final res = await api.get('/notifications/user');
    if (res is List) {
      return res.map((e) => AppNotification.fromJson(e)).toList();
    }
    return [];
  }

  // Obtener notificaciones globales (solo para admin)
  Future<List<AppNotification>> getGlobalNotifications() async {
    final res = await api.get('/notifications/admin/notifications');
    if (res is List) {
      return res.map((e) => AppNotification.fromJson(e)).toList();
    }
    return [];
  }

  //Obtener solicitudes pendientes (solo para admin)
  Future<List<AppNotification>> getPendingRequests() async {
    final res = await api.get('/notifications/admin/requests');
    if (res is List) {
      return res.map((e) => AppNotification.fromJson(e)).toList();
    }
    return [];
  }

  // Aprobar solicitud (solo para admin)
  Future<void> approveRequest(int notificationId) async {
    await api.patch('/notifications/admin/$notificationId/approve', {});
  }

  // Rechazar solicitud (solo para admin)
  Future<void> rejectRequest(int notificationId) async {
    await api.patch('/notifications/admin/$notificationId/reject', {});
  }

  // Crear notificación global (solo para admin)
  Future<AppNotification> createGlobalNotification({
    required String title,
    required String body,
  }) async {
    final res = await api.post('/notifications/send', {
      'title': title,
      'body': body,
      'user_id': null, // Global
      'is_request': false,
    });
    return AppNotification.fromJson(res);
  }

  // Eliminar notificación global (solo para admin)
  Future<void> deleteGlobalNotification(int notificationId) async {
    await api.delete('/notifications/admin/$notificationId');
  }

  // Actualizar notificación global (solo para admin)
  Future<AppNotification> updateGlobalNotification({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    final res = await api.patch('/notifications/admin/$notificationId', {
      'title': title,
      'body': body,
    });
    return AppNotification.fromJson(res);
  }

  // Marcar una notificación como leída (para usuarios normales)
  Future<void> markRead(int id) async {
    await api.patch('/notifications/user/$id/read', {});
  }
}