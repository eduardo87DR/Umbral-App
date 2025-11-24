import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notifications_provider.dart';
import '../../../models/app_notification.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';

class AdminNotificationsPage extends ConsumerWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.card,
          title: const Text("Centro de Control"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.notifications), text: "Notificaciones"),
              Tab(icon: Icon(Icons.verified), text: "Solicitudes"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationsTab(),
            _RequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTab extends ConsumerWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(globalNotificationsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () => _showNotificationDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Crear Notificación Global'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: notificationsAsync.when(
            loading: () => const LoadingWidget(message: 'Cargando notificaciones...'),
            error: (err, _) => Center(
              child: Text('Error: $err', style: const TextStyle(color: AppTheme.danger)),
            ),
            data: (notifications) => _buildNotificationsList(notifications, ref, context),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications, WidgetRef ref, BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No hay notificaciones globales',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(globalNotificationsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) => _NotificationCard(
          notification: notifications[index],
          onEdit: () => _showNotificationDialog(context, ref, notification: notifications[index]),
          onDelete: () => _showDeleteDialog(context, ref, notifications[index]),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, WidgetRef ref, {AppNotification? notification}) {
    final titleController = TextEditingController(text: notification?.title ?? '');
    final bodyController = TextEditingController(text: notification?.body ?? '');
    final isEditing = notification != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          isEditing ? 'Editar Notificación' : 'Crear Notificación Global',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => _handleNotificationSubmit(
              context, ref, 
              titleController.text, 
              bodyController.text, 
              notification?.id,
              isEditing,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationSubmit(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    String body, 
    int? notificationId,
    bool isEditing,
  ) async {
    if (title.isEmpty || body.isEmpty) {
      _showSnackbar(context, 'Completa todos los campos', isError: true);
      return;
    }

    try {
      final notifier = ref.read(globalNotificationsProvider.notifier);
      if (isEditing) {
        await notifier.updateGlobalNotification(
          notificationId: notificationId!,
          title: title,
          body: body,
        );
      } else {
        await notifier.createGlobalNotification(title: title, body: body);
      }
      Navigator.pop(context);
      _showSnackbar(context, isEditing ? 'Notificación actualizada' : 'Notificación creada');
    } catch (e) {
      _showSnackbar(context, 'Error: $e', isError: true);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Eliminar Notificación', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          '¿Eliminar "${notification.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(globalNotificationsProvider.notifier).deleteGlobalNotification(notification.id);
                Navigator.pop(context);
                _showSnackbar(context, 'Notificación eliminada');
              } catch (e) {
                _showSnackbar(context, 'Error: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return requestsAsync.when(
      loading: () => const LoadingWidget(message: 'Cargando solicitudes...'),
      error: (err, _) => Center(
        child: Text('Error: $err', style: const TextStyle(color: AppTheme.danger)),
      ),
      data: (requests) => _buildRequestsList(requests, ref, context),
    );
  }

  Widget _buildRequestsList(List<AppNotification> requests, WidgetRef ref, BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No hay solicitudes pendientes',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(pendingRequestsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, index) => _RequestCard(
          request: requests[index],
          onApprove: () => _handleRequestAction(context, ref, requests[index].id, true),
          onReject: () => _handleRequestAction(context, ref, requests[index].id, false),
        ),
      ),
    );
  }

  Future<void> _handleRequestAction(BuildContext context, WidgetRef ref, int notificationId, bool approve) async {
    try {
      final notifier = ref.read(pendingRequestsProvider.notifier);
      if (approve) {
        await notifier.approveRequest(notificationId);
        _showSnackbar(context, 'Solicitud aprobada');
      } else {
        await notifier.rejectRequest(notificationId);
        _showSnackbar(context, 'Solicitud rechazada');
      }
    } catch (e) {
      _showSnackbar(context, 'Error: $e', isError: true);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                color: AppTheme.textPrimary, 
                fontWeight: FontWeight.bold, 
                fontSize: 16
              ),
            ),
            const SizedBox(height: 8),
            Text(notification.body, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              'Creada: ${_formatDate(notification.createdAt)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AppNotification request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title,
              style: const TextStyle(
                color: AppTheme.textPrimary, 
                fontWeight: FontWeight.bold, 
                fontSize: 16
              ),
            ),
            const SizedBox(height: 8),
            Text(request.body, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              'Solicitado: ${_formatDate(request.createdAt)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                    child: const Text('Aprobar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
                    child: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.danger : AppTheme.accent,
    ),
  );
}