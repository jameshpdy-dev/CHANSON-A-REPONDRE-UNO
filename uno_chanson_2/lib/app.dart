import 'package:flutter/material.dart';

import 'core/app_constants.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class ChansonUnoApp extends StatelessWidget {
  const ChansonUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
