import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RankingTileWidget extends StatelessWidget {
  final int index;
  final dynamic item;
  final VoidCallback onViewDetails;

  const RankingTileWidget({
    super.key,
    required this.index,
    required this.item,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final username = item.username ?? 'Unknown';
    final experience = (item.experience ?? 0).toDouble();
    final victories = item.victories ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: _buildMedal(index),
        title: Text(
          username,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "${experience.toStringAsFixed(1)} XP • $victories victorias",
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.visibility,
            color: AdminTheme.adminAccent,
            size: 22,
          ),
          onPressed: onViewDetails,
        ),
      ),
    );
  }

  Widget _buildMedal(int index) {
    switch (index) {
      case 0:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.yellow, width: 2),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.yellow, size: 28),
        );
      case 1:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.grey, size: 26),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.orange, size: 24),
        );
      default:
        return CircleAvatar(
          radius: 20,
          backgroundColor: AdminTheme.adminAccent.withOpacity(0.1),
          child: Text(
            "${index + 1}",
            style: TextStyle(
              color: AdminTheme.adminAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
    }
  }
}