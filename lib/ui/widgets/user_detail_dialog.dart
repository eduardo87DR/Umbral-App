import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/stat.dart';
import '../../providers/auth_provider.dart';

class UserDetailDialog extends ConsumerStatefulWidget {
  final int userId;
  final VoidCallback onResetStats;

  const UserDetailDialog({
    super.key,
    required this.userId,
    required this.onResetStats,
  });

  @override
  ConsumerState<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<UserDetailDialog> {
  Future<PlayerStats?> _fetchAdminStats() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/admin/users/${widget.userId}/stats');
      if (res == null) return null;
      return PlayerStats.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerStats?>(
      future: _fetchAdminStats(),
      builder: (context, snapshot) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          title: const Text(
            "Detalle de usuario",
            style: TextStyle(color: Colors.white),
          ),
          content: _buildContent(snapshot),
          actions: _buildActions(snapshot),
        );
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<PlayerStats?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasError) {
      return Text(
        "No se pudieron cargar las estadísticas: ${snapshot.error}",
        style: const TextStyle(color: Colors.white70),
      );
    }

    final stats = snapshot.data;
    if (stats == null) {
      return const Text(
        "No hay estadísticas disponibles.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatsRow(label: "Experiencia", value: stats.experience.toStringAsFixed(1)),
          const SizedBox(height: 8),
          _StatsRow(label: "Victorias", value: stats.victories.toString()),
          const SizedBox(height: 8),
          _StatsRow(label: "Jefe derrotado", value: stats.bossDefeated ? "Sí" : "No"),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _buildActions(AsyncSnapshot<PlayerStats?> snapshot) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
      ),
      if (snapshot.hasData && snapshot.data != null)
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5A4)),
          onPressed: () {
            Navigator.pop(context);
            widget.onResetStats();
          },
          child: const Text("Resetear stats"),
        ),
    ];
  }
}

class _StatsRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatsRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}