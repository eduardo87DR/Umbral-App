import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notifications_repository.dart';
import '../models/app_notification.dart';
import '../providers/auth_provider.dart';

final notificationsRepoProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

// ✅ Provider para notificaciones del usuario actual (personales + globales)
final notificationsListProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>(
  (ref) => NotificationsNotifier(ref),
);

// ✅ Provider para solicitudes pendientes (solo admin)
final pendingRequestsProvider =
    StateNotifierProvider<PendingRequestsNotifier, AsyncValue<List<AppNotification>>>(
  (ref) => PendingRequestsNotifier(ref),
);

// ✅ Provider para notificaciones globales (solo admin)
final globalNotificationsProvider =
    StateNotifierProvider<GlobalNotificationsNotifier, AsyncValue<List<AppNotification>>>(
  (ref) => GlobalNotificationsNotifier(ref),
);

class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      final list = await repo.getNotifications();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead(int id) async {
    await ref.read(notificationsRepoProvider).markRead(id);
    await load();
  }
}

class PendingRequestsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref ref;

  PendingRequestsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      final list = await repo.getPendingRequests();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveRequest(int notificationId) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.approveRequest(notificationId);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectRequest(int notificationId) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.rejectRequest(notificationId);
      await load();
    } catch (e) {
      rethrow;
    }
  }
}

class GlobalNotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref ref;

  GlobalNotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      final list = await repo.getGlobalNotifications();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGlobalNotification({required String title, required String body}) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.createGlobalNotification(title: title, body: body);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGlobalNotification(int notificationId) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.deleteGlobalNotification(notificationId);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGlobalNotification({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.updateGlobalNotification(
        notificationId: notificationId,
        title: title,
        body: body,
      );
      await load();
    } catch (e) {
      rethrow;
    }
  }
}