import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Configures the application-level Material theme and metadata.
class ChansonARepondreUnoApp extends StatelessWidget {
  /// Creates the root application widget.
  const ChansonARepondreUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chanson a Repondre UNO!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.vintageTheme,
      home: const HomeScreen(),
    );
  }
}
