// widgets/search_app_bar.dart
import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String query;
  final bool showOnlyMine;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onToggleMine;
  final VoidCallback onCreateGuide;
  final VoidCallback onRefresh;

  const SearchAppBar({
    Key? key,
    required this.query,
    required this.showOnlyMine,
    required this.onQueryChanged,
    required this.onToggleMine,
    required this.onCreateGuide,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(146);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0B0B0B),
      title: const Text('Gestión de Guías', style: TextStyle(letterSpacing: 0.3)),
      actions: [
        IconButton(
          tooltip: 'Refrescar',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(86),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Buscador
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.amberAccent,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                      hintText: 'Buscar por título o contenido...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: onQueryChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Toggle: solo mis guías
              Tooltip(
                message: 'Mostrar solo mis guías',
                child: InkWell(
                  onTap: onToggleMine,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: showOnlyMine ? Colors.amberAccent : const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: showOnlyMine ? Colors.black87 : Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text('Mis guías', style: TextStyle(color: showOnlyMine ? Colors.black87 : Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                heroTag: 'createGuide',
                mini: true,
                backgroundColor: Colors.amberAccent,
                onPressed: onCreateGuide,
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}