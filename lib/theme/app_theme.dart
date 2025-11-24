import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B0B0E);
  static const Color card = Color(0xFF101217);
  static const Color accent = Color.fromARGB(255, 57, 149, 185); 
  static const Color danger = Color(0xFFB23A3A);
  static const Color textPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color textSecondary = Color.fromARGB(255, 204, 204, 204);
  static const Color surface = Color(0xFF1A1A1F);
  static const Color success = Color(0xFF4CAF50);

  static ThemeData dungeonTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        elevation: 2,
      ),
      cardColor: card,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF0F1013),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(color: accent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: accent, shape: StadiumBorder()),
      ),
    );
  }
}

class AdminTheme {
  static const Color adminAccent = Color(0xFF00B8D4); // turquesa pro
  static const Color adminHighlight = Color(0xFF14E5FF); // un poco más brillante
  static const Color adminCard = Color(0xFF0F1318);

  static ThemeData adminDungeonTheme() {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: AppTheme.background,
      primaryColor: adminAccent,
      cardColor: adminCard,
      textTheme: base.textTheme.apply(
        bodyColor: AppTheme.textPrimary,
        displayColor: AppTheme.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: adminCard,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: adminAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF11151C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(color: adminAccent),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: adminAccent,
          shape: StadiumBorder(),
        ),
      ),
    );
  }
}
