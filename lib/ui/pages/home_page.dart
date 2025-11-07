import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de bienvenida
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.shield, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, Caballero',
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Revisa el estado del reino y tus estadísticas',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Métricas principales
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  _StatCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Nivel de Experiencia',
                    value: '42',
                    color: Colors.deepPurple,
                  ),
                  _StatCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Aliados',
                    value: '128',
                    color: Colors.teal,
                  ),
                  _StatCard(
                    icon: Icons.bolt_rounded,
                    title: 'Energía Actual',
                    value: '87%',
                    color: Colors.orangeAccent,
                  ),
                  _StatCard(
                    icon: Icons.star_rounded,
                    title: 'Misiones Completas',
                    value: '23',
                    color: Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Últimas alertas o mensajes
              Text(
                'Últimos Comunicados',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const _InfoCard(
                title: 'Nueva misión disponible',
                message: 'El Consejo ha liberado una nueva misión de nivel épico.',
                icon: Icons.campaign_rounded,
                color: Colors.deepPurpleAccent,
              ),
              const _InfoCard(
                title: 'Evento global activo',
                message: 'Los portales del norte están abiertos por tiempo limitado.',
                icon: Icons.language_rounded,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta para métricas
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta para comunicados
class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
