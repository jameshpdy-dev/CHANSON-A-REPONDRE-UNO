import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/card_image_model.dart';
import '../models/deck_model.dart';
import 'local_storage_service.dart';

class DeckImportException implements Exception {
  const DeckImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

class DeckImportService {
  DeckImportService(this._storage);
  final LocalStorageService _storage;
  static const _uuid = Uuid();

  Future<List<PlatformFile>?> pickPngFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['png'],
      withData: true,
    );
    return result?.files;
  }

  Future<Deck> import(String name, List<PlatformFile> files) async {
    if (name.trim().isEmpty) {
      throw const DeckImportException('Enter a deck name.');
    }
    if (files.isEmpty) {
      throw const DeckImportException('Select at least one PNG file.');
    }
    if (files.any((file) => !file.name.toLowerCase().endsWith('.png'))) {
      throw const DeckImportException('Only PNG files can be imported.');
    }
    final id = _uuid.v4();
    Directory? directory;
    if (!kIsWeb) {
      final root = await _storage.appDirectory();
      directory = Directory('${root.path}/decks/$id');
      await directory.create(recursive: true);
    }
    final cards = <CardImageModel>[];
    final usedNames = <String>{};
    try {
      for (final file in files) {
        final bytes =
            file.bytes ??
            (file.path == null ? null : await File(file.path!).readAsBytes());
        if (bytes == null) {
          throw DeckImportException('${file.name} could not be read.');
        }
        if (!_hasPngSignature(bytes)) {
          throw DeckImportException('${file.name} is not a valid PNG file.');
        }
        final safeName = _uniqueName(file.name, usedNames);
        final storedPath = kIsWeb
            ? 'data:image/png;base64,${base64Encode(bytes)}'
            : '${directory!.path}/$safeName';
        if (!kIsWeb) {
          await File(storedPath).writeAsBytes(bytes, flush: true);
        }
        cards.add(
          CardImageModel(
            id: _uuid.v4(),
            deckId: id,
            title: safeName.substring(0, safeName.length - 4),
            path: storedPath,
            category: 'Parole',
            colour: 'red',
            importedAt: DateTime.now(),
            imageWidth: _pngInt(bytes, 16),
            imageHeight: _pngInt(bytes, 20),
          ),
        );
      }
    } on Object {
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
      rethrow;
    }
    return Deck(
      id: id,
      name: name.trim(),
      coverPath: cards.first.path,
      cards: cards,
      createdAt: DateTime.now(),
    );
  }

  bool _hasPngSignature(List<int> bytes) {
    const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    if (bytes.length < signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }

  int? _pngInt(List<int> bytes, int offset) {
    if (bytes.length < offset + 4) return null;
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  String _uniqueName(String original, Set<String> used) {
    final stem = original.substring(0, original.length - 4);
    var candidate = original;
    var index = 2;
    while (!used.add(candidate.toLowerCase())) {
      candidate = '$stem ($index).png';
      index++;
    }
    return candidate;
  }

  Future<void> deleteFiles(Deck deck) async {
    if (kIsWeb) return;
    final root = await _storage.appDirectory();
    final directory = Directory('${root.path}/decks/${deck.id}');
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
