import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'app.dart';
import 'core/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerMediaKit.ensureInitialized(windows: true, linux: true);
  if (AppConfig.hasAuthConfiguration) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl.trim(),
      publishableKey: AppConfig.supabaseAnonKey.trim(),
    );
  }
  runApp(const ChansonUnoApp());
}
