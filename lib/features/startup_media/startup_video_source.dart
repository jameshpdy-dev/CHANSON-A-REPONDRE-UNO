import 'dart:io';

enum StartupVideoMode { bundledAsset, importedFile }

sealed class StartupVideoSource {
  const StartupVideoSource();
}

class AssetStartupVideoSource extends StartupVideoSource {
  const AssetStartupVideoSource(this.assetPath);
  final String assetPath;
}

class FileStartupVideoSource extends StartupVideoSource {
  const FileStartupVideoSource(this.file);
  final File file;
}
