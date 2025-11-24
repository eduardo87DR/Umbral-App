import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../theme/app_theme.dart';

class UserCardWidget extends StatelessWidget {
  final User user;
  final User? currentUser;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;
  final VoidCallback onResetStats;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.currentUser,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeRole,
    required this.onResetStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: 20),
            Expanded(
              child: _buildUserInfo(),
            ),
            _buildActionMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 32,
      backgroundColor: AdminTheme.adminAccent.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 34,
        color: AdminTheme.adminAccent,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username con más espacio
        SizedBox(
          width: double.infinity,
          child: Text(
            user.username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 6),
        // Email con más espacio
        SizedBox(
          width: double.infinity,
          child: Text(
            user.email,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildRoleBadge(),
      ],
    );
  }

  Widget _buildRoleBadge() {
    final isAdmin = user.role == "admin";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin
            ? AdminTheme.adminAccent.withOpacity(0.15)
            : AppTheme.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? AdminTheme.adminAccent : AppTheme.accent,
          width: 1,
        ),
      ),
      child: Text(
        user.role.toUpperCase(),
        style: TextStyle(
          color: isAdmin ? AdminTheme.adminAccent : AppTheme.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton(
      color: AppTheme.card,
      icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewDetails();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'set-role':
            onChangeRole();
            break;
          case 'reset-stats':
            onResetStats();
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'view',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.visibility, size: 20, color: AdminTheme.adminAccent),
            title: const Text(
              "Ver detalles",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.edit, size: 20, color: AdminTheme.adminAccent),
            title: const Text(
              "Editar",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'set-role',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.security, size: 20, color: AdminTheme.adminAccent),
            title: const Text(
              "Cambiar rol",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reset-stats',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.restore, size: 20, color: AdminTheme.adminAccent),
            title: const Text(
              "Resetear stats",
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.delete, size: 20, color: AppTheme.danger),
            title: Text(
              "Eliminar",
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ),
      ],
    );
  }
}