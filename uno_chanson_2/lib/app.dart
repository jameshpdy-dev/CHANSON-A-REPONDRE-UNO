import 'package:flutter/material.dart';

import 'core/app_constants.dart';
import 'core/app_router.dart';
import 'theme/app_theme.dart';

class ChansonUnoApp extends StatelessWidget {
  const ChansonUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}
