import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/comments_provider.dart';
import '../../../../models/comment.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../theme/app_theme.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final int guideId;

  const CommentsSection({Key? key, required this.guideId}) : super(key: key);

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController editController = TextEditingController();

  int? editingId;

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.guideId));
    final auth = ref.watch(authStateProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comentarios",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        const SizedBox(height: 12),

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
                      "Aún no hay comentarios.",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: comments.map((c) {
                final isOwner = auth?.id == c.userId;
                final isAdmin = auth?.role == "admin";

                return _buildCommentTile(c,
                    isOwner: isOwner, isAdmin: isAdmin);
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          ),
          error: (err, _) => Text(
            "Error al cargar comentarios: $err",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),

        const SizedBox(height: 20),

        _buildAddCommentField(auth),
      ],
    );
  }

  // Añadir nuevo comentario
  Widget _buildAddCommentField(auth) {
    if (auth == null) {
      return const Text(
        "Inicia sesión para comentar.",
        style: TextStyle(color: Colors.amberAccent),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Escribe un comentario...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade800,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.amberAccent),
          onPressed: () async {
            final text = controller.text.trim();
            if (text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No puedes enviar un comentario vacío."),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            await ref
                .read(commentsProvider(widget.guideId).notifier)
                .add(text);

            controller.clear();
          },
        ),
      ],
    );
  }

  // Comentario individual
  Widget _buildCommentTile(
    Comment c, {
    required bool isOwner,
    required bool isAdmin,
  }) {
    final isEditing = editingId == c.id;

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
          // Avatar estilo red social
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.accent,
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
                // Nombre del usuario
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 6),

                // Contenido o editor
                if (isEditing)
                  TextField(
                    controller: editController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  Text(
                    c.content,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                const SizedBox(height: 8),

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

                    Row(
                      children: [
                        // EDITAR
                        if (isOwner && !isEditing)
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.amberAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                editingId = c.id;
                                editController.text = c.content;
                              });
                            },
                          ),

                        // ELIMINAR CON CONFIRMACIÓN
                        if ((isOwner || isAdmin) && !isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent, size: 20),
                            onPressed: () =>
                                _confirmDelete(context, () async {
                              await ref
                                  .read(commentsProvider(widget.guideId).notifier)
                                  .delete(c.id);
                            }),
                          ),

                        // GUARDAR / CANCELAR
                        if (isEditing)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.greenAccent),
                                onPressed: () async {
                                  final newText =
                                      editController.text.trim();

                                  if (newText.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text("El comentario no puede estar vacío."),
                                      backgroundColor: Colors.redAccent,
                                    ));
                                    return;
                                  }

                                  await ref
                                      .read(commentsProvider(widget.guideId)
                                          .notifier)
                                      .edit(c.id, newText);

                                  setState(() => editingId = null);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => editingId = null);
                                },
                              ),
                            ],
                          ),
                      ],
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

  // CONFIRM DELETE
  void _confirmDelete(BuildContext context, Function onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("¿Eliminar comentario?",
            style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          "Esta acción no se puede deshacer.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Eliminar",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FECHA
  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
}
