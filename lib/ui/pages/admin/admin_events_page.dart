import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/event.dart';
import '../../../providers/events_provider.dart';
import '../../../theme/app_theme.dart';

class AdminEventsPage extends ConsumerWidget {
  const AdminEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Gestión de Eventos"),
        backgroundColor: AppTheme.card,
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () => _openEditor(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: eventsAsync.when(
        data: (events) => RefreshIndicator(
          onRefresh: () async => ref.read(eventsListProvider.notifier).load(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            itemBuilder: (_, i) => _AdminEventCard(event: events[i]),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            "Error al cargar: $e",
            style: const TextStyle(color: AppTheme.danger),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, {Event? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EventEditor(event: event),
    );
  }
}

class _AdminEventCard extends ConsumerWidget {
  final Event event;
  const _AdminEventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  event.isActive ? Icons.check_circle : Icons.cancel,
                  color: event.isActive ? Colors.lightGreen : AppTheme.danger,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  event.isActive ? "Activo" : "Inactivo",
                  style: TextStyle(
                    color: event.isActive ?  Colors.lightGreen : AppTheme.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.accent),
                  onPressed: () => _openEdit(context, ref, event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.danger),
                  onPressed: () => _confirmDelete(context, ref, event),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref, Event e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EventEditor(event: e),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Event event) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Eliminar el evento "${event.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await ref.read(eventsListProvider.notifier).delete(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evento eliminado'),
            backgroundColor: AppTheme.accent,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}

class _EventEditor extends ConsumerStatefulWidget {
  final Event? event;
  const _EventEditor({this.event});

  @override
  ConsumerState<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends ConsumerState<_EventEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController description;
  late DateTime start;
  late DateTime end;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.event?.title ?? '');
    description = TextEditingController(text: widget.event?.description ?? '');
    start = widget.event?.startDate ?? DateTime.now();
    end = widget.event?.endDate ?? DateTime.now().add(const Duration(days: 1));
    isActive = widget.event?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? "Editar Evento" : "Crear Evento",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: title,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Título obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: description,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Descripción obligatoria' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                      onPressed: () => _selectDate(context, isStart: true),
                      child: Text('Inicio: ${_fmtDate(start)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                      onPressed: () => _selectDate(context, isStart: false),
                      child: Text('Fin: ${_fmtDate(end)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Evento activo',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                    activeColor: AppTheme.accent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _submitForm,
                      child: Text(isEditing ? 'Guardar' : 'Crear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!start.isBefore(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio debe ser anterior a la fecha de fin'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final event = Event(
      id: widget.event?.id ?? 0,
      title: title.text.trim(),
      description: description.text.trim(),
      startDate: start,
      endDate: end,
      isActive: isActive,
    );

    final notifier = ref.read(eventsListProvider.notifier);

    try {
      if (widget.event != null) {
        await notifier.update(event);
      } else {
        await notifier.add(event);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.event != null ? 'Evento actualizado' : 'Evento creado'),
          backgroundColor: AppTheme.accent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart ? start : end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          start = DateTime(picked.year, picked.month, picked.day, start.hour, start.minute);
        } else {
          end = DateTime(picked.year, picked.month, picked.day, end.hour, end.minute);
        }
      });
    }
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}