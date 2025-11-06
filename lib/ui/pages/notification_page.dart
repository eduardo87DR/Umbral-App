import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notifications_provider.dart';
import '../widgets/dungeon_appbar.dart';
import '../widgets/dungeon_card.dart';
import '../widgets/loading_widget.dart';
import '../../models/app_notification.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsListProvider);
    final notifier = ref.read(notificationsListProvider.notifier);

    return Scaffold(
      appBar: const DungeonAppBar(title: 'Notificaciones del Guardián'),
      body: RefreshIndicator(
        onRefresh: () async => await notifier.load(),
        child: notificationsState.when(
          loading: () => const LoadingWidget(message: 'Invocando mensajes...'),
          error: (err, _) => Center(
            child: Text(
              'Error al cargar notificaciones:\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (list) {
            final items = notifier.forCurrentUser();

            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No hay notificaciones por ahora.\nEl guardián permanece en silencio...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final AppNotification n = items[index];

                return DungeonCard(
                  title: n.title,
                  subtitle:
                      '${n.body}\n${n.createdAt.toLocal().toString().substring(0, 16)}',
                  trailing: n.read
                      ? const Icon(Icons.check_circle,
                          color: Colors.greenAccent)
                      : IconButton(
                          icon: const Icon(Icons.mark_email_read_outlined),
                          tooltip: 'Marcar como leída',
                          onPressed: () async {
                            await notifier.markRead(n.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notificación marcada como leída'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
