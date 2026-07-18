import 'dart:convert';
import 'dart:io';

import 'package:chanson_a_repondre_uno/data/chanson_a_repondre_uno_deck.dart';
import 'package:chanson_a_repondre_uno/models/card_item.dart';
import 'package:chanson_a_repondre_uno/repositories/card_repository.dart';
import 'package:chanson_a_repondre_uno/services/asset_card_repository.dart';
import 'package:chanson_a_repondre_uno/services/imported_card_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryImportedCardStore store;
  late AssetCardRepository repository;

  setUp(() {
    store = MemoryImportedCardStore();
    repository = AssetCardRepository(
      bundle: JsonBundle(),
      importedStore: store,
    );
  });

  test('imports one valid card with stable metadata and thumbnail', () async {
    final result = await repository.importCards([candidate('one.png')]);
    final cards = await repository.loadCards();
    final imported = cards.where((card) => card.isImported).toList();

    expect(result.imported, 1);
    expect(imported.single.id, startsWith('imported-'));
    expect(imported.single.checksum, hasLength(64));
    expect(store.thumbnails[imported.single.id], isNotEmpty);
  });

  test('preserves imported cards after repository reinitialization', () async {
    await repository.importCards([candidate('one.png')]);
    final reopened = AssetCardRepository(
      bundle: JsonBundle(),
      importedStore: store,
    );
    final imported = (await reopened.loadCards())
        .where((card) => card.isImported)
        .toList();
    expect(imported.single.title, 'one');
  });

  test(
    'rejects unsupported, oversized, and unreadable files independently',
    () async {
      final result = await repository.importCards([
        CardImportCandidate(
          filename: 'bad.gif',
          bytes: imageBytes,
          mimeType: 'image/gif',
        ),
        CardImportCandidate(
          filename: 'large.png',
          bytes: Uint8List(maxCardImageBytes + 1),
          mimeType: 'image/png',
        ),
        CardImportCandidate(
          filename: 'broken.png',
          bytes: Uint8List(0),
          mimeType: 'image/png',
        ),
        candidate('good.png'),
      ]);

      expect(result.imported, 1);
      expect(result.unsupported, 1);
      expect(result.tooLarge, 1);
      expect(result.invalid, 1);
    },
  );

  test('detects duplicate content', () async {
    final result = await repository.importCards([
      candidate('one.png'),
      candidate('renamed.png'),
    ]);
    expect(result.imported, 1);
    expect(result.duplicates, 1);
  });

  test('imports only remaining slots and never exceeds 100', () async {
    store.cards.addAll(
      List.generate(99, (index) => importedCard('existing-$index')),
    );
    final result = await repository.importCards([
      candidate('one.png'),
      CardImportCandidate(
        filename: 'two.png',
        bytes: Uint8List.fromList([...imageBytes, 0]),
        mimeType: 'image/png',
      ),
    ]);
    expect(result.imported, 1);
    expect(result.capacitySkipped, 1);
    expect((await store.load()).length, maxStoredCards);
  });

  test('rolls back failed persistence and preserves bundled cards', () async {
    store.failNextSave = true;
    final result = await repository.importCards([candidate('one.png')]);
    expect(result.errors, 1);
    expect(store.cards, isEmpty);

    store.cards.add(importedCard('imported'));
    await repository.clearImportedCards();
    final loaded = await repository.loadCards();
    expect(
      loaded.where((card) => card.source == CardSource.bundled),
      isNotEmpty,
    );
    expect(loaded.where((card) => card.isImported), isEmpty);
  });

  test('deletes one imported card', () async {
    await repository.importCards([candidate('one.png')]);
    final id = (await store.load()).single.id;
    await repository.deleteImportedCard(id);
    expect(await store.load(), isEmpty);
  });

  test('loads the permanent 67-card deck in stable order', () async {
    final cards = await repository.loadCards();
    final permanent = cards
        .where((card) => card.deckId == chansonARepondreUnoDeckId)
        .toList();

    expect(permanent, hasLength(chansonARepondreUnoCardCount));
    expect(permanent.first.id, 'chanson-a-repondre-uno-001');
    expect(permanent.last.id, 'chanson-a-repondre-uno-067');
    expect(permanent.map((card) => card.id).toSet(), hasLength(67));
    expect(
      permanent.every((card) => card.source == CardSource.bundled),
      isTrue,
    );
    expect(permanent.every((card) => !card.title.endsWith('.png')), isTrue);
  });

  test(
    'bundled deck does not count toward the 100 imported-card limit',
    () async {
      store.cards.addAll(
        List.generate(maxStoredCards, (index) => importedCard('stored-$index')),
      );

      final cards = await repository.loadCards();
      final permanent = cards
          .where((card) => card.deckId == chansonARepondreUnoDeckId)
          .toList();
      final imported = cards.where((card) => card.isImported).toList();

      expect(permanent, hasLength(chansonARepondreUnoCardCount));
      expect(imported, hasLength(maxStoredCards));
      expect(permanent.length + imported.length, 167);
    },
  );

  test('manifest lists exactly the committed permanent PNG assets', () async {
    final manifestFile = File(chansonARepondreUnoManifestPath);
    final manifest = jsonDecode(await manifestFile.readAsString()) as List;
    final pngs = Directory('assets/cards/chanson_a_repondre_uno')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .toList();

    expect(manifest, hasLength(chansonARepondreUnoCardCount));
    expect(pngs, hasLength(chansonARepondreUnoCardCount));
    expect(
      manifest.map((entry) => (entry as Map<String, dynamic>)['assetPath']),
      containsAll(pngs.map((file) => file.path.replaceAll('\\', '/'))),
    );
  });
}

final imageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

CardImportCandidate candidate(String name) => CardImportCandidate(
  filename: name,
  bytes: imageBytes,
  mimeType: 'image/png',
);

CardItem importedCard(String id) => CardItem(
  id: id,
  deckId: 'imported',
  title: id,
  question: '',
  answer: '',
  image: 'memory/$id/original',
  audio: '',
  video: '',
  category: 'Imported',
  colour: 'black',
  quote: '',
  author: '',
  year: 2026,
  tags: const [],
  favorite: false,
  source: CardSource.imported,
  thumbnail: 'memory/$id/thumbnail',
  checksum: id,
);

class JsonBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final payload = key == chansonARepondreUnoManifestPath
        ? permanentManifest
        : [bundledCard.toJson()];
    final bytes = utf8.encode(jsonEncode(payload));
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

final permanentManifest = List.generate(chansonARepondreUnoCardCount, (index) {
  final sequence = index + 1;
  final padded = sequence.toString().padLeft(3, '0');
  return {
    'id': 'chanson-a-repondre-uno-$padded',
    'deckId': chansonARepondreUnoDeckId,
    'assetPath': 'assets/cards/chanson_a_repondre_uno/card_$padded.png',
    'displayTitle': 'Card $padded',
    'source': 'bundled',
    'sequence': sequence,
  };
});

final bundledCard = CardItem(
  id: 'bundled',
  deckId: 'default',
  title: 'Bundled',
  question: '',
  answer: '',
  image: '',
  audio: '',
  video: '',
  category: '',
  colour: '',
  quote: '',
  author: '',
  year: 2026,
  tags: const [],
  favorite: false,
);

class MemoryImportedCardStore implements ImportedCardStore {
  final cards = <CardItem>[];
  final originals = <String, Uint8List>{};
  final thumbnails = <String, Uint8List>{};
  bool failNextSave = false;

  @override
  Future<void> clear(List<CardItem> values) async {
    cards.clear();
    originals.clear();
    thumbnails.clear();
  }

  @override
  Future<void> delete(CardItem card) async {
    cards.removeWhere((item) => item.id == card.id);
    originals.remove(card.id);
    thumbnails.remove(card.id);
  }

  @override
  Future<List<CardItem>> load() async => List.of(cards);

  @override
  Future<Uint8List?> read(String reference) async {
    final parts = reference.split('/');
    return parts.last == 'thumbnail'
        ? thumbnails[parts[1]]
        : originals[parts[1]];
  }

  @override
  Future<({String original, String thumbnail})> references(
    String id,
    String extension,
  ) async =>
      (original: 'memory/$id/original', thumbnail: 'memory/$id/thumbnail');

  @override
  Future<void> save(
    CardItem card,
    Uint8List original,
    Uint8List thumbnail,
  ) async {
    if (failNextSave) {
      failNextSave = false;
      throw StateError('simulated storage failure');
    }
    cards.add(card);
    originals[card.id] = original;
    thumbnails[card.id] = thumbnail;
  }
}
