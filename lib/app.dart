import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'theme/app_theme.dart';

/// Configures the application-level Material theme and metadata.
class ChansonARepondreUnoApp extends StatelessWidget {
  /// Creates the root application widget.
  const ChansonARepondreUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chanson a Repondre UNO!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.vintageTheme,
      routerConfig: AppRouter.router,
    );
  }
}
