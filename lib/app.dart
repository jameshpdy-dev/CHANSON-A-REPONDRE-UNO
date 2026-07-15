import 'package:flutter/material.dart';

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
      home: const _ProjectPlaceholder(),
    );
  }
}

/// Provides a stable starting surface until the home experience is introduced.
class _ProjectPlaceholder extends StatelessWidget {
  /// Creates the project placeholder.
  const _ProjectPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chanson a Repondre UNO!')),
    );
  }
}
