import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../services/local_storage_service.dart';
import 'startup_video_source.dart';

class StartupVideoException implements Exception {
  const StartupVideoException(this.message);
  final String message;
  @override
  String toString() => message;
}

class StartupVideoStorage {
  StartupVideoStorage(this._storage);

  static const bundledAsset = 'assets/videos/startup_video.mp4';
  static const preferenceKey = 'startup_video_preferences';
  static const supportedExtensions = {'mp4', 'mov', 'm4v', 'webm'};
  static const maxBytes = 500 * 1024 * 1024;
  final LocalStorageService _storage;

  Future<StartupVideoSource> resolve() async {
    final encoded = await _storage.read(preferenceKey);
    if (encoded != null) {
      try {
        final data = jsonDecode(encoded) as Map<String, dynamic>;
        if (data['startupVideoMode'] == StartupVideoMode.importedFile.name) {
          final file = File(data['startupVideoLocalPath'] as String);
          if (await file.exists() && await file.length() > 0) {
            return FileStartupVideoSource(file);
          }
          await _storage.remove(preferenceKey);
        }
      } on Object {
        await _storage.remove(preferenceKey);
      }
    }
    return const AssetStartupVideoSource(bundledAsset);
  }

  Future<File> importVideo(File source) async {
    await _validateFile(source);
    final directory = Directory(
      path.join((await _storage.appDirectory()).path, 'media'),
    );
    await directory.create(recursive: true);
    final extension = path.extension(source.path).toLowerCase();
    final temporary = File(
      path.join(directory.path, 'startup_video.pending$extension'),
    );
    if (await temporary.exists()) await temporary.delete();
    await source.copy(temporary.path);
    await _validateController(VideoPlayerController.file(temporary));

    final destination = File(
      path.join(directory.path, 'startup_video$extension'),
    );
    if (await destination.exists()) await destination.delete();
    final imported = await temporary.rename(destination.path);
    await _storage.write(preferenceKey, {
      'startupVideoMode': StartupVideoMode.importedFile.name,
      'startupVideoLocalPath': imported.path,
      'startupVideoFileName': path.basename(source.path),
      'startupVideoUpdatedAt': DateTime.now().toIso8601String(),
    });
    return imported;
  }

  Future<void> restoreDefault() async {
    final source = await resolve();
    await _storage.remove(preferenceKey);
    if (source is FileStartupVideoSource && await source.file.exists()) {
      await source.file.delete();
    }
  }

  Future<void> _validateFile(File file) async {
    final extension = path
        .extension(file.path)
        .toLowerCase()
        .replaceFirst('.', '');
    if (!supportedExtensions.contains(extension)) {
      throw const StartupVideoException(
        'Choose an MP4, MOV, M4V, or WebM video.',
      );
    }
    if (!await file.exists()) {
      throw const StartupVideoException('The selected video no longer exists.');
    }
    final size = await file.length();
    if (size <= 0) {
      throw const StartupVideoException('The selected video is empty.');
    }
    if (size > maxBytes) {
      throw const StartupVideoException(
        'This video is too large to use as the startup video.',
      );
    }
    await _validateController(VideoPlayerController.file(file));
  }

  Future<void> _validateController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      final value = controller.value;
      if (value.duration <= Duration.zero ||
          value.size.width <= 0 ||
          value.size.height <= 0) {
        throw const StartupVideoException(
          'The selected file is not a valid playable video.',
        );
      }
    } on StartupVideoException {
      rethrow;
    } on Object {
      throw const StartupVideoException(
        'The selected video could not be initialized.',
      );
    } finally {
      await controller.dispose();
    }
  }
}
