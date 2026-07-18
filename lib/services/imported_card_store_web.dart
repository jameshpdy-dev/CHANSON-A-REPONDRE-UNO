import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart';

import '../models/card_item.dart';
import 'imported_card_store.dart';

class PlatformImportedCardStore implements ImportedCardStore {
  static const _store = 'cards';
  Future<Database> get _database => idbFactoryBrowser.open(
        'chanson_a_repondre_cards',
        version: 1,
        onUpgradeNeeded: (event) {
          final db = event.database;
          if (!db.objectStoreNames.contains(_store)) {
            db.createObjectStore(_store, keyPath: 'id');
          }
        },
      );

  @override
  Future<({String original, String thumbnail})> references(
    String id,
    String extension,
  ) async =>
      (original: 'idb/$id/original', thumbnail: 'idb/$id/thumbnail');

  @override
  Future<List<CardItem>> load() async {
    final db = await _database;
    final transaction = db.transaction(_store, idbModeReadOnly);
    final values = await transaction.objectStore(_store).getAll();
    await transaction.completed;
    return values
        .map((value) => CardItem.fromJson(
              Map<String, dynamic>.from(
                (value as Map)['metadata'] as Map,
              ),
            ))
        .toList(growable: false);
  }

  @override
  Future<void> save(
    CardItem card,
    Uint8List original,
    Uint8List thumbnail,
  ) async {
    final db = await _database;
    final transaction = db.transaction(_store, idbModeReadWrite);
    await transaction.objectStore(_store).put({
      'id': card.id,
      'metadata': card.toJson(),
      'original': original,
      'thumbnail': thumbnail,
    });
    await transaction.completed;
  }

  @override
  Future<Uint8List?> read(String reference) async {
    final parts = reference.split('/');
    if (parts.length != 3) return null;
    final db = await _database;
    final transaction = db.transaction(_store, idbModeReadOnly);
    final value = await transaction.objectStore(_store).getObject(parts[1]);
    await transaction.completed;
    if (value is! Map) return null;
    final bytes = value[parts[2]];
    return bytes is Uint8List ? bytes : Uint8List.fromList(List<int>.from(bytes as List));
  }

  @override
  Future<void> delete(CardItem card) async {
    final db = await _database;
    final transaction = db.transaction(_store, idbModeReadWrite);
    await transaction.objectStore(_store).delete(card.id);
    await transaction.completed;
  }

  @override
  Future<void> clear(List<CardItem> cards) async {
    final db = await _database;
    final transaction = db.transaction(_store, idbModeReadWrite);
    await transaction.objectStore(_store).clear();
    await transaction.completed;
  }
}
