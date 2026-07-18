import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_set.dart';
import '../models/card_set_import_source.dart';
import '../repositories/card_set_repository.dart';

/// Persists browser-imported PNG card sets through browser local storage.
class CardSetImportRepository implements CardSetRepository {
  /// Creates a browser-backed card-set repository.
  const CardSetImportRepository();

  static const _indexKey = 'card_set_import_index';

  @override
  Future<List<CardSet>> loadCardSets() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(_indexKey);
    if (source == null) {
      return const [];
    }
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => CardSet.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<CardSet> importPngCardSet({
    required String deckName,
    required List<CardSetImportSource> sources,
  }) async {
    final pngSources = sources
        .where((source) => source.name.toLowerCase().endsWith('.png'))
        .toList();
    if (pngSources.isEmpty ||
        pngSources.any((source) => source.bytes == null)) {
      throw const FormatException(
        'Select PNG card images using the file picker.',
      );
    }
    final safeName = deckName.trim().isEmpty
        ? 'Imported Card Set'
        : deckName.trim();
    final cards = pngSources.indexed
        .map((entry) {
          final fileName = entry.$2.name;
          return ImportedCardImage(
            id: '${safeName.toLowerCase()}-${entry.$1 + 1}',
            title: fileName
                .replaceAll(RegExp(r'\.png$', caseSensitive: false), '')
                .replaceAll(RegExp('[_-]+'), ' '),
            imagePath: 'data:image/png;base64,${base64Encode(entry.$2.bytes!)}',
          );
        })
        .toList(growable: false);
    final cardSet = CardSet(
      id: '${safeName.toLowerCase()}-${DateTime.now().microsecondsSinceEpoch}',
      name: safeName,
      cards: cards,
      createdAt: DateTime.now(),
    );
    final preferences = await SharedPreferences.getInstance();
    final sets = [...await loadCardSets(), cardSet];
    await preferences.setString(
      _indexKey,
      jsonEncode(sets.map((set) => set.toJson()).toList()),
    );
    return cardSet;
  }
}
