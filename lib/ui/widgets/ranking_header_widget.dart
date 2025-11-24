// ranking_header_widget.dart
import 'package:flutter/material.dart';

class RankingHeaderWidget extends StatelessWidget {
  const RankingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ranking de Jugadores", 
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Top 10 jugadores según su experiencia acumulada",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }
}