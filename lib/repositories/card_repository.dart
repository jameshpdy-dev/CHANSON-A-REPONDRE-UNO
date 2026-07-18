import '../models/card_item.dart';
import 'dart:typed_data';

/// Defines the card data operations consumed by application features.
abstract interface class CardRepository {
  /// Loads every card available to the application.
  Future<List<CardItem>> loadCards();

  Future<ImportBatchResult> importCards(
    List<CardImportCandidate> candidates, {
    void Function(int completed, int total)? onProgress,
  });

  Future<void> deleteImportedCard(String id);

  Future<void> clearImportedCards();

  Future<Uint8List?> readStoredImage(String reference);
}

const int maxStoredCards = 100;
const int maxCardImageBytes = 10 * 1024 * 1024;

class CardImportCandidate {
  const CardImportCandidate({
    required this.filename,
    required this.bytes,
    this.mimeType,
  });
  final String filename;
  final Uint8List bytes;
  final String? mimeType;
}

class ImportBatchResult {
  const ImportBatchResult({
    this.imported = 0,
    this.duplicates = 0,
    this.invalid = 0,
    this.tooLarge = 0,
    this.unsupported = 0,
    this.capacitySkipped = 0,
    this.errors = 0,
  });
  final int imported;
  final int duplicates;
  final int invalid;
  final int tooLarge;
  final int unsupported;
  final int capacitySkipped;
  final int errors;
}
