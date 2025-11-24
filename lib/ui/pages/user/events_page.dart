import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notifications_provider.dart';
import '../../../models/event.dart';
import '../../../models/app_notification.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';

final _loadingProvider = StateProvider.family<bool, int>((ref, eventId) => false);

class EventsPage extends ConsumerWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider);
    final notifsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Eventos del Umbral',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: notifsAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando notificaciones...'),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red))
        ),
        data: (notifs) => eventsAsync.when(
          loading: () => const LoadingWidget(message: 'Cargando eventos...'),
          error: (err, _) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.red))
          ),
          data: (events) => _EventsContent(events: events, notifs: notifs),
        ),
      ),
    );
  }
}

class _EventsContent extends ConsumerWidget {
  final List<Event> events;
  final List<AppNotification> notifs;

  const _EventsContent({required this.events, required this.notifs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () async {
        await ref.read(notificationsListProvider.notifier).load();
        await ref.read(eventsListProvider.notifier).load();
      },
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeader(),
          const SizedBox(height: 22),
          if (events.isEmpty)
            _buildEmptyState()
          else
            ...events.map((e) => _EventCard(event: e, notifs: notifs)),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF141421),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Column(
      children: [
        Text(
          'Eventos del Umbral',
          style: TextStyle(
            color: Colors.amberAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Participa en misiones especiales, completa desafíos únicos\ny reclama recompensas exclusivas.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 60),
      child: Text('No hay eventos registrados.', style: TextStyle(color: Colors.white60, fontSize: 15)),
    ),
  );
}

class _EventCard extends ConsumerWidget {
  final Event event;
  final List<AppNotification> notifs;

  const _EventCard({required this.event, required this.notifs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).asData?.value?.id ?? -1;
    final status = _eventStatus(event, notifs, userId);

    final isActive = event.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF161622),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEventDetails(context, ref, event, notifs, userId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildEventIcon(isActive),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEventInfo(event, status),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventIcon(bool isActive) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: (isActive ? Colors.greenAccent : Colors.grey).withOpacity(0.18),
      shape: BoxShape.circle,
    ),
    child: Icon(
      isActive ? Icons.local_fire_department : Icons.hourglass_empty,
      size: 26,
      color: isActive ? Colors.greenAccent : Colors.grey,
    ),
  );

  Widget _buildEventInfo(Event event, String status) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        event.title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(
        event.description.isNotEmpty ? event.description : 'Sin descripción disponible',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white60, fontSize: 13),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.amberAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            '${_fmt(event.startDate)} → ${_fmt(event.endDate)}',
            style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
          ),
          const SizedBox(width: 10),
          _buildSmallStatusBadge(status),
        ],
      ),
    ],
  );

  Widget _buildSmallStatusBadge(String status) {
    final config = switch (status) {
      'pending' => _BadgeConfig(Colors.orange, Icons.hourglass_empty, 'Pendiente'),
      'approved' => _BadgeConfig(Colors.green, Icons.check_circle, 'Completado'),
      'rejected' => _BadgeConfig(Colors.redAccent, Icons.refresh, 'Rechazado'),
      _ => null,
    };

    if (config == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(config.text,
            style: TextStyle(color: config.color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showEventDetails(BuildContext context, WidgetRef ref, Event e, List<AppNotification> notifs, int userId) {
    showDialog(
      context: context,
      builder: (_) => _EventDetailDialogWrapper(event: e, userId: userId),
    );
  }
}

class _EventDetailDialogWrapper extends ConsumerWidget {
  final Event event;
  final int userId;
  const _EventDetailDialogWrapper({required this.event, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsListProvider);

    return notifsAsync.when(
      data: (notifs) => EventDetailDialog(event: event, status: _eventStatus(event, notifs, userId), userId: userId),
      loading: () => EventDetailDialog(event: event, status: 'none', userId: userId),
      error: (_, __) => EventDetailDialog(event: event, status: 'none', userId: userId),
    );
  }
}

class EventDetailDialog extends ConsumerWidget {
  final Event event;
  final String status;
  final int userId;
  const EventDetailDialog({required this.event, required this.status, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(_loadingProvider(event.id));

    return AlertDialog(
      backgroundColor: const Color(0xFF161622),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(event.title, style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 12),
          _info(Icons.calendar_today, 'Inicio: ${_fmt(event.startDate)}'),
          const SizedBox(height: 6),
          _info(Icons.flag, 'Fin: ${_fmt(event.endDate)}'),
          const SizedBox(height: 14),
          _statusLarge(event.isActive),
          const SizedBox(height: 18),
          _statusBadgeLarge(status),
        ]),
      ),
      actions: _actions(context, ref, isLoading, status),
    );
  }

  Widget _info(icon, text) => Row(children: [
    Icon(icon, color: Colors.amberAccent, size: 14),
    const SizedBox(width: 6),
    Text(text, style: const TextStyle(color: Colors.white70)),
  ]);

  Widget _statusLarge(isActive) => Row(children: [
    Icon(isActive ? Icons.check_circle : Icons.cancel,
        color: isActive ? Colors.greenAccent : Colors.redAccent, size: 18),
    const SizedBox(width: 6),
    Text(
      isActive ? 'Evento activo' : 'Evento inactivo',
      style: TextStyle(color: isActive ? Colors.greenAccent : Colors.redAccent),
    ),
  ]);

  List<Widget> _actions(context, ref, isLoading, current) => [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cerrar', style: TextStyle(color: Colors.amberAccent)),
    ),

    if (current == 'pending')
      ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.5),
          foregroundColor: Colors.white60,
        ),
        child: const Text('Esperando'),
      ),

    if (current == 'rejected')
      ElevatedButton(
        onPressed: isLoading ? null : () => _send(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
        child: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Reenviar'),
      ),

    if (current == 'none')
      ElevatedButton(
        onPressed: isLoading ? null : () => _send(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.black,
        ),
        child: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Solicitar'),
      ),
  ];

  Future<void> _send(context, ref) async {
    final notifier = ref.read(notificationsListProvider.notifier);
    final loading = ref.read(_loadingProvider(event.id).notifier);

    try {
      loading.state = true;

      final repo = ref.read(notificationsRepoProvider);
      await repo.api.post('/notifications/event/${event.id}/request-review', {});

      await notifier.load();

      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 120));

      showDialog(
        context: context,
        builder: (_) => _EventDetailDialogWrapper(event: event, userId: userId),
      );
    } 
    finally {
      loading.state = false;
    }
  }

  Widget _statusBadgeLarge(String status) {
    final config = switch (status) {
      'pending' => _BadgeConfig(Colors.orange, Icons.hourglass_empty, 'Pendiente'),
      'approved' => _BadgeConfig(Colors.green, Icons.check_circle, 'Completado'),
      'rejected' => _BadgeConfig(Colors.redAccent, Icons.close, 'Rechazado'),
      _ => _BadgeConfig(Colors.white70, Icons.info, 'Sin completar'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color),
          const SizedBox(width: 8),
          Text(config.text, style: TextStyle(color: config.color)),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _BadgeConfig {
  final Color color;
  final IconData icon;
  final String text;
  _BadgeConfig(this.color, this.icon, this.text);
}

String _eventStatus(Event e, List<AppNotification> notifs, int userId) {
  final hasPending = notifs.any((n) => n.isRequest == true && n.handled == false && n.requestedBy == userId && n.eventId == e.id);
  if (hasPending) return 'pending';

  final hasApproved = notifs.any((n) => n.title.toLowerCase().contains('aprobada') && n.userId == userId && n.body.contains(e.title));
  if (hasApproved) return 'approved';

  final hasRejected = notifs.any((n) => n.title.toLowerCase().contains('rechazada') && n.userId == userId && n.body.contains(e.title));
  if (hasRejected) return 'rejected';

  return 'none';
}
