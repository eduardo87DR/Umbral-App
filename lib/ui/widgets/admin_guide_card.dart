import 'package:flutter/material.dart';
import '../../models/guide.dart';

class AdminGuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPreview;

  const AdminGuideCard({
    Key? key,
    required this.guide,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
  }) : super(key: key);

  String _snippet(String content, [int len = 120]) {
    final clean = content.replaceAll('\n', ' ').trim();
    if (clean.length <= len) return clean;
    return '${clean.substring(0, len).trim()}...';
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF121214),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    guide.title,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Vista previa',
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility, color: Colors.white70),
                ),
                PopupMenuButton<String>(
                  color: const Color(0xFF141414),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Eliminar'))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // snippet + meta
            Text(
              _snippet(guide.content),
              style: const TextStyle(color: Colors.white70, height: 1.3),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  backgroundColor: const Color(0xFF171717),
                  label: Text('Autor: ${guide.authorName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  avatar: const Icon(Icons.person, size: 16, color: Colors.white54),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: const Color(0xFF171717),
                  label: Text('Publicado: ${_formatDate(guide.createdAt)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  avatar: const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}