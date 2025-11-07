import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/guides_provider.dart';
import '../widgets/dungeon_card.dart';
class GuidesPage extends ConsumerWidget {
  const GuidesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(guidesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guías del Aventurero'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1D), Color(0xFF2E2E33)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(guidesListProvider),
          color: Colors.amberAccent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),

              // 🧭 Título
              const Text(
                "Guías del Umbral",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),

              const SizedBox(height: 8),

              // 📜 Descripción
              Text(
                "En este apartado encontrarás diferentes guías creadas por aventureros del Umbral. "
                "Explora estrategias, secretos, builds de personajes y conocimientos que te ayudarán "
                "a sobrevivir más allá de la puerta del guardián.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // 📖 Contenido dinámico
              guidesAsync.when(
                data: (guides) {
                  if (guides.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          'No hay guías disponibles por ahora.\n¡Sé el primero en escribir una!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: guides.map((g) {
                      return DungeonCard(
                        title: g.title,
                        subtitle: "${g.category} · ${_formatDate(g.createdAt)}",
                        trailing: const Icon(Icons.menu_book_rounded, color: Colors.amberAccent),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.grey.shade900,
                              title: Text(g.title,
                                  style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold)),
                              content: SingleChildScrollView(
                                child: Text(
                                  g.content,
                                  style: TextStyle(color: Colors.grey.shade200, fontSize: 15),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cerrar", style: TextStyle(color: Colors.amberAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(color: Colors.amberAccent),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      'Error al cargar las guías: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
