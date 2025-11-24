import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/ranking_provider.dart';
import '../../widgets/loading_widget.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final rankingAsync = ref.watch(publicRankingProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text(
            'Estadísticas del Jugador',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.textPrimary,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(icon: Icon(Icons.bar_chart), text: "Stats"),
              Tab(icon: Icon(Icons.leaderboard), text: "Ranking"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //TAB STATS
            statsAsync.when(
              data: (stats) {
                if (stats == null) {
                  return const Center(
                    child: Text(
                      'No hay estadísticas disponibles.',
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen general',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Consulta tu desempeño acumulado dentro de Umbral.',
                        style: TextStyle(fontSize: 14, color: Colors.white60),
                      ),
                      const SizedBox(height: 24),

                      _buildStatCard(
                        icon: Icons.emoji_events_rounded,
                        title: 'Victorias Totales',
                        value: stats.victories.toString(),
                        color: AppTheme.accent,
                      ),

                      _buildStatCard(
                        icon: Icons.flash_on_rounded,
                        title: 'Experiencia Acumulada',
                        value: '${stats.experience.toStringAsFixed(1)} XP',
                        color: AppTheme.accent,
                      ),

                      _buildStatCard(
                        icon: Icons.shield_outlined,
                        title: 'Jefe derrotado',
                        value: stats.bossDefeated ? 'Sí' : 'No',
                        color: stats.bossDefeated ? Colors.greenAccent : AppTheme.danger,
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              ref.read(statsProvider.notifier).load(),
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Actualizar estadísticas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(message: "Cargando estadísticas..."),
              error: (e, _) => Center(
                child: Text(
                  'Error al cargar estadísticas:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ),
            ),

            // TAB RANKING
            rankingAsync.when(
              data: (ranking) {
                if (ranking.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay jugadores en el ranking.",
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ranking Global",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Consulta el top de jugadores según su experiencia acumulada.",
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView.builder(
                          itemCount: ranking.length,
                          itemBuilder: (context, i) {
                            final entry = ranking[i];

                            IconData? specialIcon;
                            Color? specialColor;

                            if (i == 0) {
                              specialIcon = Icons.emoji_events_rounded;
                              specialColor = Colors.yellow[600];
                            } else if (i == 1) {
                              specialIcon = Icons.emoji_events_rounded;
                              specialColor = Colors.grey[400];
                            } else if (i == 2) {
                              specialIcon = Icons.emoji_events_rounded;
                              specialColor = Colors.brown[300];
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 0.8,
                                ),
                              ),
                              child: ListTile(
                                leading: specialIcon != null
                                    ? Icon(
                                        specialIcon,
                                        color: specialColor,
                                        size: 30,
                                      )
                                    : CircleAvatar(
                                        backgroundColor: AppTheme.accent,
                                        child: Text(
                                          "${i + 1}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                title: Text(
                                  entry.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "${entry.experience.toStringAsFixed(1)} XP",
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.military_tech,
                                        color: AppTheme.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${entry.victories}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(message: "Cargando ranking..."),
              error: (e, _) => Center(
                child: Text(
                  'Error al cargar ranking:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMPONENTE CARD STATS
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white10,
          width: .8,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
