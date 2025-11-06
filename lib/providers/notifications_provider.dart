import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notifications_repository.dart';
import '../models/app_notification.dart';
import 'auth_provider.dart';

final notificationsRepoProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

final notificationsListProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>(
  (ref) => NotificationsNotifier(ref),
);

class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      final list = await repo.getNotifications(limit: 20, offset: 0);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mostrar solo notificaciones para el user actual en UI:
  List<AppNotification> forCurrentUser() {
    final auth = ref.read(authStateProvider);
    final currentUser = auth.asData?.value;
    if (state is AsyncData<List<AppNotification>>) {
      final items = (state as AsyncData<List<AppNotification>>).value;
      if (currentUser == null) {
        // mostrar solo las que son globales (user_id == null)
        return items.where((n) => n.userId == null).toList();
      } else {
        return items.where((n) => n.userId == null || n.userId == currentUser.id).toList();
      }
    }
    return [];
  }

  Future<void> sendNotification({required String title, required String body, required int userId}) async {
    await ref.read(notificationsRepoProvider).send(title: title, body: body, userId: userId);
    await load();
  }

  Future<void> markRead(int id) async {
    await ref.read(notificationsRepoProvider).markRead(id);
    await load();
  }
}
