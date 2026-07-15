import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/card_set.dart';
import '../models/card_set_import_source.dart';
import '../repositories/card_set_repository.dart';

/// Persists imported PNG card sets in the app's writable data directory.
class CardSetImportRepository implements CardSetRepository {
  /// Creates a native file-system backed card-set repository.
  const CardSetImportRepository();

  static const _indexName = 'card_sets.json';

  @override
  Future<List<CardSet>> loadCardSets() async {
    final indexFile = await _indexFile();
    if (!await indexFile.exists()) {
      return const [];
    }
    final decoded = jsonDecode(await indexFile.readAsString()) as List<dynamic>;
    return decoded
        .map((item) => CardSet.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<CardSet> importPngCardSet({
    required String deckName,
    required List<CardSetImportSource> sources,
  }) async {
    final pngSources = await _collectPngSources(sources);
    if (pngSources.isEmpty) {
      throw const FormatException('Select at least one PNG card image.');
    }

    final safeName = _safeFolderName(deckName);
    final root = await _storageRoot();
    final deckDirectory = Directory('${root.path}${Platform.pathSeparator}$safeName');
    await deckDirectory.create(recursive: true);

    final cards = <ImportedCardImage>[];
    for (var index = 0; index < pngSources.length; index++) {
      final source = pngSources[index];
      final fileName = _uniqueFileName(source.name, index);
      final destination = File('${deckDirectory.path}${Platform.pathSeparator}$fileName');
      final bytes = source.bytes ?? await File(source.path!).readAsBytes();
      await destination.writeAsBytes(bytes, flush: true);
      cards.add(
        ImportedCardImage(
          id: '$safeName-${index + 1}',
          title: _titleFromFileName(fileName),
          imagePath: destination.path,
        ),
      );
    }

    final cardSet = CardSet(
      id: '$safeName-${DateTime.now().microsecondsSinceEpoch}',
      name: deckName.trim().isEmpty ? 'Imported Card Set' : deckName.trim(),
      cards: cards,
      createdAt: DateTime.now(),
    );
    await File('${deckDirectory.path}${Platform.pathSeparator}cards.json')
        .writeAsString(jsonEncode(cards.map((card) => card.toJson()).toList()), flush: true);
    final sets = [...await loadCardSets(), cardSet];
    await (await _indexFile()).writeAsString(
      jsonEncode(sets.map((set) => set.toJson()).toList()),
      flush: true,
    );
    return cardSet;
  }

  Future<List<CardSetImportSource>> _collectPngSources(
    List<CardSetImportSource> sources,
  ) async {
    final result = <CardSetImportSource>[];
    for (final source in sources) {
      final path = source.path;
      if (path != null && await Directory(path).exists()) {
        await for (final entity in Directory(path).list(recursive: true)) {
          if (entity is File && _isPng(entity.path)) {
            result.add(CardSetImportSource(name: entity.uri.pathSegments.last, path: entity.path));
          }
        }
      } else if (_isPng(source.name)) {
        result.add(source);
      }
    }
    return result;
  }

  Future<Directory> _storageRoot() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}${Platform.pathSeparator}cards')
      ..createSync(recursive: true);
  }

  Future<File> _indexFile() async => File('${(await _storageRoot()).path}${Platform.pathSeparator}$_indexName');

  bool _isPng(String value) => value.toLowerCase().endsWith('.png');

  String _safeFolderName(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    return normalized.replaceAll(RegExp(r'(^_+|_+$)'), '').isEmpty
        ? 'imported_card_set'
        : normalized;
  }

  String _uniqueFileName(String name, int index) {
    final stem = name.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
    return '${stem.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_')}_${index + 1}.png';
  }

  String _titleFromFileName(String name) {
    final stem = name.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
    return stem.replaceAll(RegExp('[_-]+'), ' ').trim();
  }
}
