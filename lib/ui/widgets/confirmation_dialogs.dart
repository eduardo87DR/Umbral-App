// confirmation_dialogs.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../theme/app_theme.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final User user;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Confirmar Eliminación", 
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "¿Seguro que deseas eliminar al usuario \"${user.username}\"? Esta acción es irreversible.",
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text("Eliminar"),
        ),
      ],
    );
  }
}

class ResetStatsConfirmationDialog extends StatelessWidget {
  final User user;
  final VoidCallback onConfirm;

  const ResetStatsConfirmationDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Resetear Estadísticas", 
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "¿Deseas resetear las estadísticas de \"${user.username}\"? Esto establecerá nivel 1, experiencia 0 y victorias 0.",
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.adminAccent),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text("Resetear"),
        ),
      ],
    );
  }
}