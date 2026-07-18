import 'package:flutter/material.dart';

/// Defines the shared vintage visual foundation for the application.
abstract final class AppTheme {
  /// The light Material 3 theme used by the application.
  static final ThemeData vintageTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD5A53C),
      brightness: Brightness.dark,
      surface: const Color(0xFF20170D),
    ),
    scaffoldBackgroundColor: const Color(0xFF120E09),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: Color(0xFFFFE2A4),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: Color(0xFFFFF4DC),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    ),
  );
}
