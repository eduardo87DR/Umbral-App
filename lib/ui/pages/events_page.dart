import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';
import '../widgets/loading_widget.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17), // Fondo oscuro tipo calabozo
      appBar: AppBar(
        title: const Text('Eventos del Umbral'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1B2E),
      ),
      body: eventsAsync.when(
        data: (events) => RefreshIndicator(
          onRefresh: () async => ref.read(eventsListProvider.notifier).load(),
          color: AppTheme.accent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sección de introducción
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1B2E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Eventos del Umbral',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Estos son los eventos activos dentro del juego Umbral. '
                      'Explora desafíos únicos, descubre secretos y no te pierdas '
                      'ninguna misión especial del calabozo.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Lista de eventos
              if (events.isEmpty)
                const Center(
                  child: Text(
                    'No hay eventos registrados por ahora.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                ...events.map((e) => _EventCard(event: e)),
            ],
          ),
        ),
        loading: () => const Center(
          child: LoadingWidget(message: 'Cargando eventos...'),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error al cargar eventos: $err',
            style: const TextStyle(color: AppTheme.danger),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final activeColor = event.isActive ? Colors.greenAccent : Colors.grey;
    final icon = event.isActive ? Icons.local_fire_department : Icons.bolt;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1C1C2B),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showEventDetails(context, event);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.15),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: activeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.description.isNotEmpty
                          ? event.description
                          : 'Sin descripción disponible.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.amberAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_fmt(event.startDate)} → ${_fmt(event.endDate)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.amberAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showEventDetails(BuildContext context, Event e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          e.title,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.description,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.amberAccent, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Inicio: ${_fmt(e.startDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.amberAccent, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Fin: ${_fmt(e.endDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  e.isActive ? Icons.check_circle : Icons.cancel,
                  color: e.isActive ? Colors.greenAccent : Colors.redAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  e.isActive ? 'Evento activo' : 'Evento inactivo',
                  style: TextStyle(
                    color: e.isActive ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: Colors.amberAccent)),
          ),
        ],
      ),
    );
  }
}
