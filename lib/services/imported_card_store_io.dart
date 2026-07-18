import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../models/card_item.dart';
import 'imported_card_store.dart';

class PlatformImportedCardStore implements ImportedCardStore {
  Future<Directory> get _root async {
    final support = await getApplicationSupportDirectory();
    final root = Directory('${support.path}${Platform.pathSeparator}cards');
    await Directory('${root.path}${Platform.pathSeparator}originals')
        .create(recursive: true);
    await Directory('${root.path}${Platform.pathSeparator}thumbnails')
        .create(recursive: true);
    return root;
  }

  @override
  Future<({String original, String thumbnail})> references(
    String id,
    String extension,
  ) async {
    final root = await _root;
    return (
      original:
          '${root.path}${Platform.pathSeparator}originals${Platform.pathSeparator}$id.$extension',
      thumbnail:
          '${root.path}${Platform.pathSeparator}thumbnails${Platform.pathSeparator}$id.png',
    );
  }

  @override
  Future<List<CardItem>> load() async {
    final root = await _root;
    final metadata = File('${root.path}${Platform.pathSeparator}cards.json');
    if (!await metadata.exists()) return const [];
    final decoded = jsonDecode(await metadata.readAsString()) as List<dynamic>;
    final cards = <CardItem>[];
    for (final value in decoded) {
      final card = CardItem.fromJson(value as Map<String, dynamic>);
      if (await File(card.image).exists()) cards.add(card);
    }
    return cards;
  }

  @override
  Future<void> save(
    CardItem card,
    Uint8List original,
    Uint8List thumbnail,
  ) async {
    final originalFile = File(card.image);
    final thumbnailFile = File(card.thumbnail!);
    try {
      await originalFile.writeAsBytes(original, flush: true);
      await thumbnailFile.writeAsBytes(thumbnail, flush: true);
      final cards = await load();
      await _writeMetadata([...cards, card]);
    } catch (_) {
      if (await originalFile.exists()) await originalFile.delete();
      if (await thumbnailFile.exists()) await thumbnailFile.delete();
      rethrow;
    }
  }

  @override
  Future<Uint8List?> read(String reference) async {
    final file = File(reference);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> delete(CardItem card) async {
    final cards = await load();
    await _writeMetadata(cards.where((item) => item.id != card.id).toList());
    for (final path in [card.image, card.thumbnail]) {
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
  }

  @override
  Future<void> clear(List<CardItem> cards) async {
    await _writeMetadata(const []);
    for (final card in cards) {
      for (final path in [card.image, card.thumbnail]) {
        if (path != null) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
      }
    }
  }

  Future<void> _writeMetadata(List<CardItem> cards) async {
    final root = await _root;
    final target = File('${root.path}${Platform.pathSeparator}cards.json');
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(cards.map((card) => card.toJson()).toList()),
      flush: true,
    );
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }
}
