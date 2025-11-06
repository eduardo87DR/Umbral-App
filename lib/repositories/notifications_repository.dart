import '../services/api_client.dart';
import '../models/app_notification.dart';

class NotificationsRepository {
  final ApiClient api;

  NotificationsRepository(this.api);

  /// Obtiene la lista de notificaciones (retorna lista de AppNotification).
  /// La API devuelve un objeto { total, limit, offset, items: [...] } según tu ejemplo.
  Future<List<AppNotification>> getNotifications({int limit = 20, int offset = 0}) async {
    final res = await api.get('/notifications/', query: {'limit': '$limit', 'offset': '$offset'});
    // Manejar respuesta con estructura { items: [...] } o una lista directa
    if (res is Map && res['items'] != null && res['items'] is List) {
      return (res['items'] as List).map((e) => AppNotification.fromJson(e)).toList();
    } else if (res is List) {
      return res.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  /// Envía una notificación. Tu backend acepta una ruta GET: /notifications/send?title=...&body=...&user_id=...
  /// Adaptamos usando GET con query parameters.
  Future<void> send({required String title, required String body, required int userId}) async {
    await api.get('/notifications/send', query: {
      'title': title,
      'body': body,
      'user_id': '$userId',
    });
  }

  /// Marca una notificación como leída (PATCH /notifications/{id}/read)
  Future<AppNotification> markRead(int id) async {
    final res = await api.patch('/notifications/$id/read', {});
    return AppNotification.fromJson(res);
  }
}
