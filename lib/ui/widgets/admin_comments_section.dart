// widgets/admin_comments_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/comments_provider.dart';
import '../../../../models/comment.dart';

class AdminCommentsSection extends ConsumerStatefulWidget {
  final int guideId;

  const AdminCommentsSection({Key? key, required this.guideId}) : super(key: key);

  @override
  ConsumerState<AdminCommentsSection> createState() => _AdminCommentsSectionState();
}

class _AdminCommentsSectionState extends ConsumerState<AdminCommentsSection> {

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.guideId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comentarios de Usuarios",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Como administrador, puedes ver y eliminar comentarios inapropiados",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      "No hay comentarios en esta guía.",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: comments.map((c) => _buildCommentTile(c)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.amberAccent),
            ),
          ),
          error: (err, _) => Text(
            "Error al cargar comentarios: $err",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  // Comentario individual para admin
  Widget _buildCommentTile(Comment c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade800, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.amber,
            child: Text(
              c.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del usuario e información
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.username,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'ID Usuario: ${c.userId}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón eliminar (siempre visible para admin)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(context, c),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Contenido del comentario
                Text(
                  c.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

                const SizedBox(height: 8),

                // Fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(c.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatTime(c.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CONFIRM DELETE mejorado para admin
  void _confirmDelete(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("Eliminar Comentario", style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Estás seguro de que quieres eliminar este comentario?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Usuario: ${comment.username}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "Comentario: ${comment.content.length > 50 ? '${comment.content.substring(0, 50)}...' : comment.content}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Esta acción no se puede deshacer.",
              style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(commentsProvider(widget.guideId).notifier).delete(comment.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Comentario de ${comment.username} eliminado'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Error al eliminar: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  
  String _formatTime(DateTime d) => "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
}