import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final userState = ref.watch(authStateProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: userState.when(
          data: (user) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dashboard, color: AdminTheme.adminAccent, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      'Panel de Control',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  'Resumen general del sistema',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 22),

                statsAsync.when(
                  data: (stats) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: [
                      _AdminStatCard(
                        icon: Icons.people,
                        label: "Usuarios",
                        value: "${stats['users'] ?? 0}",
                        color: Colors.tealAccent,
                      ),
                      _AdminStatCard(
                        icon: Icons.event,
                        label: "Eventos",
                        value: "${stats['events'] ?? 0}",
                        color: Colors.amberAccent,
                      ),
                      _AdminStatCard(
                        icon: Icons.menu_book,
                        label: "Guías",
                        value: "${stats['guides'] ?? 0}",
                        color: Colors.deepPurpleAccent,
                      ),
                      _AdminStatCard(
                        icon: Icons.notifications_active,
                        label: "Pendientes",
                        value: "${stats['pending'] ?? 0}",
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  loading: () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: const [
                      _AdminStatCard(icon: Icons.people, label: "Usuarios", value: "...", color: Colors.tealAccent),
                      _AdminStatCard(icon: Icons.event, label: "Eventos", value: "...", color: Colors.amberAccent),
                      _AdminStatCard(icon: Icons.menu_book, label: "Guías", value: "...", color: Colors.deepPurpleAccent),
                      _AdminStatCard(icon: Icons.notifications_active, label: "Pendientes", value: "...", color: Colors.orangeAccent),
                    ],
                  ),
                  error: (error, stack) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: const [
                      _AdminStatCard(icon: Icons.people, label: "Usuarios", value: "Error", color: Colors.grey),
                      _AdminStatCard(icon: Icons.event, label: "Eventos", value: "Error", color: Colors.grey),
                      _AdminStatCard(icon: Icons.menu_book, label: "Guías", value: "Error", color: Colors.grey),
                      _AdminStatCard(icon: Icons.notifications_active, label: "Pendientes", value: "Error", color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                Text(
                  "Actividad Reciente",
                  style: textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                const _RecentCard(
                  icon: Icons.person_add,
                  title: "Nuevo usuario registrado",
                  message: "Se ha agregado un nuevo jugador al sistema.",
                ),
                const _RecentCard(
                  icon: Icons.bolt,
                  title: "Evento actualizado",
                  message: "Un evento ha sido modificado por un admin.",
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.danger))),
        ),
      ),
    );
  }
}


class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AdminStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.adminCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withOpacity(0.3), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}



class _RecentCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _RecentCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AdminTheme.adminCard,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.25),
          child: Icon(icon, color: Colors.deepPurpleAccent, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
