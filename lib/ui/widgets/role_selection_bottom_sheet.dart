// role_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../providers/users_provider.dart';
import '../../../theme/app_theme.dart';

class RoleSelectionBottomSheet extends ConsumerWidget {
  final User user;

  const RoleSelectionBottomSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Cambiar rol de ${user.username}",
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoleTile(
            context,
            ref,
            role: 'admin',
            title: "Administrador",
            subtitle: "Acceso completo al sistema",
            icon: Icons.workspace_premium,
            color: AdminTheme.adminAccent,
          ),
          const SizedBox(height: 12),
          _buildRoleTile(
            context,
            ref,
            role: 'user',
            title: "Usuario",
            subtitle: "Acceso estándar",
            icon: Icons.person,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRoleTile(
    BuildContext context,
    WidgetRef ref, {
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: user.role == role ? color.withOpacity(0.15) : Colors.transparent,
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title, 
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
      onTap: () => _onRoleSelected(context, ref, role),
    );
  }

  void _onRoleSelected(BuildContext context, WidgetRef ref, String role) async {
    Navigator.pop(context);
    final notifier = ref.read(usersListProvider.notifier);
    try {
      await notifier.updateRole(user.id, role);
      await ref.read(usersListProvider.notifier).load();
      _showRoleUpdateSnackbar(context, role);
    } catch (e) {
      _showRoleErrorSnackbar(context, e);
    }
  }

  void _showRoleUpdateSnackbar(BuildContext context, String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rol actualizado a ${role.toUpperCase()}"),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showRoleErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al actualizar rol: $error"),
        backgroundColor: AppTheme.danger,
      ),
    );
  }
}