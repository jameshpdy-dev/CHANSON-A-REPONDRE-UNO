import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'app.dart';
import 'core/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerMediaKit.ensureInitialized(windows: true, linux: true);
  String? authenticationInitializationError;
  if (kDebugMode) {
    debugPrint('Supabase configured: ${AppConfig.hasAuthConfiguration}');
    debugPrint(
      'Backend URL: ${AppConfig.aiBackendUrl.isEmpty ? '(not configured)' : AppConfig.aiBackendUrl}',
    );
  }
  if (AppConfig.hasAuthConfiguration) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl.trim(),
        publishableKey: AppConfig.supabaseClientKey,
      );
    } on Object {
      authenticationInitializationError =
          'Authentication initialization failed. Check the Supabase project configuration.';
    }
  }
  runApp(
    ChansonUnoApp(
      authenticationInitializationError: authenticationInitializationError,
    ),
  );
}
