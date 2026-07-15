import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/card_image_model.dart';
import '../models/deck_model.dart';
import 'deck_storage_service.dart';

/// Copies selected PNG files into a new locally persisted deck.
class DeckImportService {
  /// Creates a deck importer using application storage.
  const DeckImportService(this._storage);

  final DeckStorageService _storage;

  /// Imports validated PNG files as one deck without changing file bytes.
  Future<DeckModel> importDeck({
    required String deckName,
    required List<PlatformFile> files,
  }) async {
    final pngFiles = files
        .where(
          (file) =>
              file.name.toLowerCase().endsWith('.png') && file.path != null,
        )
        .toList(growable: false);
    if (pngFiles.isEmpty) {
      throw const FormatException('Select one or more PNG files.');
    }
    final name = deckName.trim();
    if (name.isEmpty) {
      throw const FormatException('Enter a deck name.');
    }
    final deckId = 'deck_${DateTime.now().microsecondsSinceEpoch}';
    final root = await _storage.decksDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}$deckId');
    await directory.create(recursive: true);
    final cards = <CardImageModel>[];
    final usedNames = <String>{};
    for (var index = 0; index < pngFiles.length; index++) {
      final file = pngFiles[index];
      final targetName = _uniqueName(file.name, usedNames);
      final targetPath =
          '${directory.path}${Platform.pathSeparator}$targetName';
      await File(file.path!).copy(targetPath);
      cards.add(
        CardImageModel(
          id: '$deckId-${index + 1}',
          title: _titleFromName(targetName),
          path: targetPath,
        ),
      );
    }
    return DeckModel(
      id: deckId,
      name: name,
      cards: cards,
      createdAt: DateTime.now(),
    );
  }

  String _uniqueName(String name, Set<String> usedNames) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    var candidate = name;
    var copy = 2;
    while (!usedNames.add(candidate.toLowerCase())) {
      candidate = '$stem ($copy++).png';
    }
    return candidate;
  }

  String _titleFromName(String name) => name
      .replaceAll(RegExp(r'\.png$', caseSensitive: false), '')
      .replaceAll(RegExp('[_-]+'), ' ')
      .trim();
}
