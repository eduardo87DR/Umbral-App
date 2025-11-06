import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/guides_provider.dart';
import '../../providers/stats_provider.dart';
import '../widgets/dungeon_appbar.dart';
import '../widgets/dungeon_card.dart';
import '../widgets/loading_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guides = ref.watch(guidesListProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const DungeonAppBar(title: 'Sala del Héroe'),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(guidesListProvider.notifier).load();
          await ref.read(statsProvider.notifier).load();
        },
        color: Colors.deepPurpleAccent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Estadísticas del Calabozo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            stats.when(
              data: (list) => Column(
                children: list
                    .map((s) => DungeonCard(
                          title: s.label,
                          subtitle: 'Valor: ${s.value}',
                          trailing: const Icon(Icons.bar_chart, color: Colors.white54),
                        ))
                    .toList(),
              ),
              loading: () => const LoadingWidget(message: 'Consultando estadísticas...'),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Guías disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            guides.when(
              data: (list) => Column(
                children: list
                    .map((g) => DungeonCard(
                          title: g.title,
                          subtitle: g.category,
                          trailing: const Icon(Icons.menu_book_rounded, color: Colors.white54),
                          onTap: () {
                            // Más adelante puedes navegar a una página de detalle
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Abrir guía: ${g.title}')),
                            );
                          },
                        ))
                    .toList(),
              ),
              loading: () => const LoadingWidget(message: 'Invocando guías...'),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
