import 'package:flutter/material.dart';

/// Defines the shared vintage visual foundation for the application.
abstract final class AppTheme {
  /// The light Material 3 theme used by the application.
  static final ThemeData vintageTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A6428),
      brightness: Brightness.light,
      surface: const Color(0xFFF3E8D1),
    ),
  );
}
