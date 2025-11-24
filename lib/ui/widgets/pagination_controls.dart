// widgets/pagination_controls.dart
import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startItem = (currentPage * pageSize) + 1;
    final endItem = ((currentPage + 1) * pageSize).clamp(0, totalItems);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          // Información de paginación
          Text(
            'Mostrando $startItem-$endItem de $totalItems guías',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          // Controles de paginación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón anterior
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white70),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              ),
              
              // Números de página
              Wrap(
                spacing: 4,
                children: List.generate(totalPages, (index) {
                  final isCurrent = index == currentPage;
                  
                  return GestureDetector(
                    onTap: () => onPageChanged(index),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.amberAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? Colors.amberAccent : Colors.white24,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white70,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Botón siguiente
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white70),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}