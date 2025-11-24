import 'package:flutter/material.dart';

class DungeonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const DungeonAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true, required TabBar bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 3,
      backgroundColor: Colors.black87,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
