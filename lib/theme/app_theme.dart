import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B0B0E);
  static const Color card = Color(0xFF101217);
  static const Color accent = Color(0xFF9B7B3E); 
  static const Color danger = Color(0xFFB23A3A);
  static const Color textPrimary = Color(0xFFECE6D6);

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
