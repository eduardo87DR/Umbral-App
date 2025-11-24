import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guides_provider.dart';
import '../../models/guide.dart';

class GuideFormDialog extends ConsumerStatefulWidget {
  final Guide? guide;
  const GuideFormDialog({Key? key, this.guide}) : super(key: key);

  @override
  ConsumerState<GuideFormDialog> createState() => _GuideFormDialogState();
}

class _GuideFormDialogState extends ConsumerState<GuideFormDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.guide?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.guide?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text('Título y contenido son obligatorios')));
      return;
    }

    setState(() => _saving = true);
    try {
      final notifier = ref.read(guidesListProvider.notifier);
      if (widget.guide != null) {
        // actualizar
        await ref.read(guidesRepoProvider).updateGuide(widget.guide!.id, Guide(
          id: widget.guide!.id,
          title: title,
          content: content,
          authorId: widget.guide!.authorId,
          authorName: widget.guide!.authorName,
          createdAt: widget.guide!.createdAt,
        ));
      } else {
        // crear
        await notifier.add(Guide(
          id: 0,
          title: title,
          content: content,
          authorId: ref.read(authStateProvider).value?.id ?? 0,
          authorName: ref.read(authStateProvider).value?.username ?? '',
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.guide != null;
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(isEdit ? 'Editar Guía' : 'Crear Guía', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentCtrl,
                maxLines: 12,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Contenido',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
          child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Text(isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}