import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/guides_provider.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/comments_section.dart';

class GuidesPage extends ConsumerWidget {
  const GuidesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(guidesListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.card,
        title: const Text(
          "Guías del Aventurero",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.background,
              Color(0xFF0A0A0D),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(guidesListProvider),
          color: AppTheme.accent,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const SizedBox(height: 10),

              const Text(
                "Guías del Umbral",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Descubre estrategias, secretos y estudios registrados por exploradores experimentados. Interpreta cada guía como un manual arcano vivo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // LISTA
              guidesAsync.when(
                data: (guides) {
                  if (guides.isEmpty) {
                    return Column(
                      children: const [
                        SizedBox(height: 70),
                        Text(
                          "Aún no hay guías registradas.\nComienza con la primera escritura.",
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: guides.map((g) {
                      final preview = _extractPreview(g.content);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accent.withOpacity(.22),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(.12),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openGuideDialog(context, g),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: AppTheme.accent,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      g.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                _formatDate(g.createdAt),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                preview,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Icon(Icons.comment, size: 18, color: Colors.amber),
                                  SizedBox(width: 6),
                                  Text(
                                    "Ver comentarios",
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },

                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  ),
                ),

                error: (err, _) => Center(
                  child: Text(
                    "Error al cargar guías: $err",
                    style: const TextStyle(color: AppTheme.danger),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // MÉTODOS AUXILIARES

  String _extractPreview(String content) {
    if (content.length <= 120) return content;
    return content.substring(0, 120) + "...";
  }

  void _openGuideDialog(BuildContext context, guide) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                guide.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        guide.content,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CommentsSection(guideId: guide.id),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
