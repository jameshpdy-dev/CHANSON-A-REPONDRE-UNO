import 'dart:typed_data';

import '../models/card_item.dart';
import 'imported_card_store_io.dart'
    if (dart.library.html) 'imported_card_store_web.dart';

abstract interface class ImportedCardStore {
  factory ImportedCardStore() = PlatformImportedCardStore;

  Future<List<CardItem>> load();
  Future<({String original, String thumbnail})> references(
    String id,
    String extension,
  );
  Future<void> save(CardItem card, Uint8List original, Uint8List thumbnail);
  Future<Uint8List?> read(String reference);
  Future<void> delete(CardItem card);
  Future<void> clear(List<CardItem> cards);
}
