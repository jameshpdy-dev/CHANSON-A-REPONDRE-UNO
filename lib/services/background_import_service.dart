import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum BackgroundMediaType { image, video }

class BackgroundImportException implements Exception {
  const BackgroundImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PendingBackgroundImport {
  const PendingBackgroundImport({
    required this.name,
    required this.bytes,
    required this.type,
  });
  final String name;
  final Uint8List bytes;
  final BackgroundMediaType type;
}

class BackgroundImportService {
  Future<PendingBackgroundImport?> pickImage() => _pick(
    type: BackgroundMediaType.image,
    extensions: const ['png', 'jpg', 'jpeg'],
  );

  Future<PendingBackgroundImport?> pickVideo() =>
      _pick(type: BackgroundMediaType.video, extensions: const ['mp4']);

  Future<PendingBackgroundImport?> _pick({
    required BackgroundMediaType type,
    required List<String> extensions,
  }) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (result == null) return null;
    final selected = result.files.single;
    final extension = selected.extension?.toLowerCase();
    if (extension == null || !extensions.contains(extension)) {
      throw BackgroundImportException(
        'Unsupported file. Choose ${extensions.join(', ').toUpperCase()}.',
      );
    }
    final bytes =
        selected.bytes ??
        (selected.path == null
            ? null
            : await File(selected.path!).readAsBytes());
    if (bytes == null || bytes.isEmpty) {
      throw const BackgroundImportException(
        'The selected file could not be read.',
      );
    }
    if (type == BackgroundMediaType.image && !_isImage(bytes, extension)) {
      throw const BackgroundImportException(
        'The selected file is not a valid PNG or JPEG image.',
      );
    }
    if (type == BackgroundMediaType.video && !_isMp4(bytes)) {
      throw const BackgroundImportException(
        'The selected file is not a valid MP4 video.',
      );
    }
    return PendingBackgroundImport(
      name: selected.name,
      bytes: bytes,
      type: type,
    );
  }

  Future<String> save(PendingBackgroundImport pending) async {
    if (kIsWeb) {
      throw const BackgroundImportException(
        'Background file import requires desktop or mobile application storage.',
      );
    }
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/backgrounds');
    await directory.create(recursive: true);
    final extension = pending.name.split('.').last.toLowerCase();
    final file = File(
      '${directory.path}/background_${pending.type.name}.$extension',
    );
    await file.writeAsBytes(pending.bytes, flush: true);
    return file.path;
  }

  Future<void> deleteIfManaged(String? path) async {
    if (path == null || kIsWeb) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  bool _isImage(Uint8List bytes, String extension) {
    if (extension == 'png') {
      const signature = [137, 80, 78, 71, 13, 10, 26, 10];
      return bytes.length >= 8 && listEquals(bytes.take(8).toList(), signature);
    }
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  bool _isMp4(Uint8List bytes) =>
      bytes.length >= 12 && String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp';
}
