import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6), // Tailwind Blue-500
      secondary: Color(0xFFF59E0B), // Tailwind Amber-500
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937), // Tailwind Gray-800
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: const Color(0xFF1F2937),
  );
}
