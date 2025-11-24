import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_dashboard_provider.dart';
import '../../../theme/app_theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(userDashboardStatsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: userState.when(
          data: (user) {
            final username = user?.username ?? "Guerrero";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.accent,
                        child: Icon(Icons.shield, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido, $username',
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .8,
                            ),
                          ),
                          Text(
                            'Revisa tu estado y progreso',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // MÉTRICAS
                  statsAsync.when(
                    data: (stats) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: .95,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: [
                        _StatCard(
                          icon: Icons.bar_chart_rounded,
                          title: 'Nivel',
                          value: '${stats['level'] ?? 1}',
                          color: Colors.amberAccent,
                        ),
                        _StatCard(
                          icon: Icons.event_available_rounded,
                          title: 'Eventos Activos',
                          value: '${stats['active_events'] ?? 0}',
                          color: Colors.teal,
                        ),
                        _StatCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Guías Disponibles',
                          value: '${stats['available_guides'] ?? 0}',
                          color: Colors.deepPurpleAccent,
                        ),
                        _StatCard(
                          icon: Icons.notifications_rounded,
                          title: 'Revisiones Pendientes',
                          value: '${stats['pending_items'] ?? 0}',
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                    loading: () => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: .95,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: const [
                        _StatCard(icon: Icons.bar_chart_rounded, title: 'Nivel', value: '...', color: Colors.amberAccent),
                        _StatCard(icon: Icons.event_available_rounded, title: 'Eventos Activos', value: '...', color: Colors.teal),
                        _StatCard(icon: Icons.menu_book_rounded, title: 'Guías', value: '...', color: Colors.deepPurpleAccent),
                        _StatCard(icon: Icons.notifications_rounded, title: 'Pendientes', value: '...', color: Colors.orangeAccent),
                      ],
                    ),
                    error: (e, _) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: .95,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: const [
                        _StatCard(icon: Icons.bar_chart_rounded, title: 'Nivel', value: '1', color: Colors.amberAccent),
                        _StatCard(icon: Icons.event_available_rounded, title: 'Eventos Activos', value: '0', color: Colors.teal),
                        _StatCard(icon: Icons.menu_book_rounded, title: 'Guías', value: '0', color: Colors.deepPurpleAccent),
                        _StatCard(icon: Icons.notifications_rounded, title: 'Pendientes', value: '0', color: Colors.orangeAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // COMUNICADOS
                  Text(
                    'Últimos Comunicados',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const _InfoCard(
                    title: 'Nueva misión disponible',
                    message: 'El Consejo ha liberado una misión de nivel épico.',
                    icon: Icons.campaign_rounded,
                  ),
                  const _InfoCard(
                    title: 'Evento global activo',
                    message: 'Los portales del norte están abiertos por tiempo limitado.',
                    icon: Icons.language_rounded,
                  ),
                ],
              ),
            );
          },

          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          ),

          error: (e, _) => Center(
            child: Text(
              '$e',
              style: const TextStyle(color: AppTheme.danger),
            ),
          ),
        ),
      ),
    );
  }
}

// TARJETAS DE MÉTRICAS
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// TARJETAS DE INFO
class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.accent.withOpacity(.25),
          child: Icon(icon, color: AppTheme.accent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          message,
          style: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}
