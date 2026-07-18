import '../models/card_set.dart';
import '../models/card_set_import_source.dart';

/// Defines persistence operations for user-imported PNG card sets.
abstract interface class CardSetRepository {
  /// Restores all previously imported sets.
  Future<List<CardSet>> loadCardSets();

  /// Filters, copies, and registers a new PNG-only card set.
  Future<CardSet> importPngCardSet({
    required String deckName,
    required List<CardSetImportSource> sources,
  });
}
