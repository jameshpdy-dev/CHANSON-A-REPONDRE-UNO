import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

enum BackgroundMediaType { video }

class BackgroundProvider extends ChangeNotifier {
  BackgroundProvider(this._storage);
  final LocalStorageService _storage;
  static const _key = 'background_settings';

  BackgroundMediaType type = BackgroundMediaType.video;
  String currentFilename = 'home_background.mp4';
  double darkOverlay = .28;
  bool muteVideo = true;

  String get videoPath => 'assets/videos/home_background.mp4';

  Future<void> load() async {
    try {
      final source = await _storage.read(_key);
      if (source != null) {
        final map = jsonDecode(source) as Map<String, dynamic>;
        darkOverlay = ((map['overlay'] as num?)?.toDouble() ?? .28).clamp(
          0,
          .6,
        );
        muteVideo = map['muteVideo'] as bool? ?? true;
      }
    } on Object {
      // Defaults recover from corrupt preferences.
    }
    type = BackgroundMediaType.video;
    currentFilename = 'home_background.mp4';
    notifyListeners();
  }

  Future<void> setOverlay(double value) async {
    darkOverlay = value.clamp(0, .6);
    await _persist();
  }

  Future<void> setMuteVideo(bool value) async {
    muteVideo = value;
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.write(_key, {
      'type': type.name,
      'filename': currentFilename,
      'overlay': darkOverlay,
      'muteVideo': muteVideo,
    });
    notifyListeners();
  }
}
