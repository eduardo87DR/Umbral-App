// widgets/guide_preview_dialog.dart (versión actualizada)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guide.dart';
import 'admin_comments_section.dart';

class GuidePreviewDialog extends ConsumerStatefulWidget {
  final Guide guide;

  const GuidePreviewDialog({Key? key, required this.guide}) : super(key: key);

  @override
  ConsumerState<GuidePreviewDialog> createState() => _GuidePreviewDialogState();
}

class _GuidePreviewDialogState extends ConsumerState<GuidePreviewDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vista Previa: ${widget.guide.title}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Contenido con tabs
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Tabs
                    Container(
                      color: Colors.grey.shade800,
                      child: const TabBar(
                        labelColor: Colors.amberAccent,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.amberAccent,
                        tabs: [
                          Tab(icon: Icon(Icons.article), text: 'Contenido'),
                          Tab(icon: Icon(Icons.comment), text: 'Comentarios'),
                        ],
                      ),
                    ),
                    
                    // Contenido de los tabs
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Contenido de la guía
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Autor:', widget.guide.authorName ?? 'Desconocido'),
                                _buildInfoRow('Publicado:', _formatDate(widget.guide.createdAt)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Contenido:',
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.guide.content,
                                    style: const TextStyle(color: Colors.white70, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Tab 2: Comentarios
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: AdminCommentsSection(guideId: widget.guide.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}