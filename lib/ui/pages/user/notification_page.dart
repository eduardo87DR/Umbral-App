import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notifications_provider.dart';
import '../../../models/app_notification.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/dungeon_card.dart';
import '../../../theme/app_theme.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsListProvider);
    final notifier = ref.read(notificationsListProvider.notifier);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppTheme.background,

        appBar: AppBar(
          backgroundColor: AppTheme.background,
          centerTitle: true,
          elevation: 4,

          title: Text(
            'Notificaciones del Guardián',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),

          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: Colors.lightGreen,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.notifications_active), text: "Nuevas"),
              Tab(icon: Icon(Icons.history), text: "Leídas"),
            ],
          ),
        ),

        body: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.background,
          onRefresh: () async => await notifier.load(),

          child: notificationsState.when(
            loading: () =>
                const LoadingWidget(message: 'Invocando mensajes...'),

            error: (err, _) => Center(
              child: Text(
                'Error al cargar notificaciones:\n$err',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.danger,
                  fontSize: 15,
                ),
              ),
            ),

            data: (items) {
              final unread = items.where((n) => !n.read).toList();
              final read = items.where((n) => n.read).toList();

              return TabBarView(
                children: [

                  /// NUEVAS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                        child: Text(
                          "Aquí verás los avisos recientes enviados por el guardián.\n"
                          "Úsalos para mantenerte informado de eventos y alertas activas.",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _NotificationsList(
                          titleWhenEmpty:
                          'No hay notificaciones nuevas.\nEl guardián permanece en silencio...',
                          items: unread,
                          onMarkRead: (n) async {
                            await notifier.markRead(n.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.accent,
                                content: Text(
                                  'Notificación marcada como leída',
                                  style: TextStyle(color: AppTheme.textPrimary),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  /// LEÍDAS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                        child: Text(
                          "Historial de notificaciones ya revisadas.\n"
                          "Consulta mensajes que marcaste anteriormente.",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _NotificationsList(
                          titleWhenEmpty:
                              'No has marcado ninguna notificación como leída.',
                          items: read,
                          readMode: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

//   LISTA DE NOTIFICACIONES

class _NotificationsList extends StatelessWidget {
  final List<AppNotification> items;
  final String titleWhenEmpty;
  final bool readMode;
  final Future<void> Function(AppNotification)? onMarkRead;

  const _NotificationsList({
    required this.items,
    required this.titleWhenEmpty,
    this.readMode = false,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            titleWhenEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final n = items[index];

        return DungeonCard(
          title: n.title,
          subtitle:
              '${n.body}\n${n.createdAt.toLocal().toString().substring(0, 16)}',

          trailing:
              readMode
                  ? Icon(Icons.check_circle, color: Colors.lime)
                  : PopupMenuButton(
                      color: AppTheme.background,
                      icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read_outlined,
                                  color: AppTheme.accent),
                              const SizedBox(width: 10),
                              Text("Marcar como leída",
                                  style: TextStyle(color: AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'read' && onMarkRead != null) {
                          onMarkRead!(n);
                        }
                      },
                    ),
        );
      },
    );
  }
}
