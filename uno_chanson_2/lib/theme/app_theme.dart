import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color gold = Color(0xFFFFC928);
  static const Color paleGold = Color(0xFFFFE5A3);

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      surface: const Color(0xFF17130D),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: paleGold,
          fontSize: 27,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFFFF3D1),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
