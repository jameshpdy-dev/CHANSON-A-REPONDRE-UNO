import 'dart:convert';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import '../data/chanson_a_repondre_uno_deck.dart';
import '../models/card_item.dart';
import '../repositories/card_repository.dart';
import 'imported_card_store.dart';

/// Loads the initial card collection from the bundled JSON asset.
class AssetCardRepository implements CardRepository {
  /// Creates an asset-backed card repository.
  AssetCardRepository({this.bundle, ImportedCardStore? importedStore})
    : _importedStore = importedStore ?? ImportedCardStore();

  /// An optional bundle used for controlled loading in tests and integrations.
  final AssetBundle? bundle;
  final ImportedCardStore _importedStore;

  @override
  Future<List<CardItem>> loadCards() async {
    final source = await (bundle ?? rootBundle).loadString(
      'assets/json/cards.json',
    );
    final decoded = jsonDecode(source) as List<dynamic>;
    final bundled = decoded
        .map((item) => CardItem.fromJson(item as Map<String, dynamic>))
        .toList();
    bundled.addAll(await _loadChansonARepondreUnoCards());
    final imported = await _importedStore.load();
    return [...bundled, ...imported];
  }

  @override
  Future<ImportBatchResult> importCards(
    List<CardImportCandidate> candidates, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final stored = await _importedStore.load();
    final checksums = stored
        .map((card) => card.checksum)
        .whereType<String>()
        .toSet();
    var imported = 0;
    var duplicates = 0;
    var invalid = 0;
    var tooLarge = 0;
    var unsupported = 0;
    var capacitySkipped = 0;
    var errors = 0;
    final slots = maxStoredCards - stored.length;
    final accepted = candidates.take(slots).toList(growable: false);
    capacitySkipped = candidates.length - accepted.length;

    for (var index = 0; index < accepted.length; index++) {
      final candidate = accepted[index];
      try {
        final extension = _extension(candidate.filename);
        final expectedMime = _mimeFor(extension);
        if (expectedMime == null ||
            (candidate.mimeType != null &&
                candidate.mimeType!.isNotEmpty &&
                !_mimeMatches(candidate.mimeType!, extension))) {
          unsupported++;
          continue;
        }
        if (candidate.bytes.isEmpty) {
          invalid++;
          continue;
        }
        if (candidate.bytes.length > maxCardImageBytes) {
          tooLarge++;
          continue;
        }
        final checksum = sha256.convert(candidate.bytes).toString();
        if (!checksums.add(checksum)) {
          duplicates++;
          continue;
        }
        final thumbnail = await _thumbnail(candidate.bytes);
        final id = 'imported-${DateTime.now().microsecondsSinceEpoch}-$index';
        final refs = await _importedStore.references(id, extension);
        final title = candidate.filename.replaceFirst(RegExp(r'\.[^.]+$'), '');
        final card = CardItem(
          id: id,
          deckId: 'imported',
          title: title,
          question: '',
          answer: '',
          image: refs.original,
          audio: '',
          video: '',
          category: 'Imported',
          colour: 'black',
          quote: '',
          author: '',
          year: DateTime.now().year,
          tags: const ['imported'],
          favorite: false,
          source: CardSource.imported,
          originalFilename: candidate.filename,
          thumbnail: refs.thumbnail,
          mimeType: expectedMime,
          sizeBytes: candidate.bytes.length,
          importedAt: DateTime.now().toUtc(),
          checksum: checksum,
        );
        await _importedStore.save(card, candidate.bytes, thumbnail);
        imported++;
      } on FormatException {
        invalid++;
      } catch (_) {
        errors++;
      } finally {
        onProgress?.call(index + 1, accepted.length);
      }
    }
    return ImportBatchResult(
      imported: imported,
      duplicates: duplicates,
      invalid: invalid,
      tooLarge: tooLarge,
      unsupported: unsupported,
      capacitySkipped: capacitySkipped,
      errors: errors,
    );
  }

  @override
  Future<void> deleteImportedCard(String id) async {
    final cards = await _importedStore.load();
    final card = cards.where((item) => item.id == id).firstOrNull;
    if (card != null) await _importedStore.delete(card);
  }

  @override
  Future<void> clearImportedCards() async {
    final cards = await _importedStore.load();
    await _importedStore.clear(cards);
  }

  @override
  Future<Uint8List?> readStoredImage(String reference) =>
      _importedStore.read(reference);

  Future<List<CardItem>> _loadChansonARepondreUnoCards() async {
    final source = await (bundle ?? rootBundle).loadString(
      chansonARepondreUnoManifestPath,
    );
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) {
          final json = item as Map<String, dynamic>;
          final sequence = json['sequence'] as int;
          final title = json['displayTitle'] as String;
          return CardItem(
            id: json['id'] as String,
            deckId: chansonARepondreUnoDeckId,
            title: title,
            question: '$chansonARepondreUnoDeckName permanent card $sequence',
            answer: '',
            image: json['assetPath'] as String,
            audio: '',
            video: '',
            category: chansonARepondreUnoDeckName,
            colour: 'black',
            quote: '',
            author: '',
            year: 2026,
            tags: [
              chansonARepondreUnoDeckName,
              title,
              'card $sequence',
              'card ${sequence.toString().padLeft(3, '0')}',
              'permanent deck',
              'bundled',
            ],
            favorite: false,
            source: CardSource.bundled,
          );
        })
        .toList(growable: false);
  }

  static String _extension(String filename) =>
      filename.split('.').last.toLowerCase();

  static String? _mimeFor(String extension) => switch (extension) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    _ => null,
  };

  static bool _mimeMatches(String mime, String extension) {
    final normalized = mime.toLowerCase();
    return normalized == _mimeFor(extension) ||
        (extension == 'jpg' && normalized == 'image/jpg') ||
        (extension == 'jpeg' && normalized == 'image/jpg');
  }

  static Future<Uint8List> _thumbnail(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    final scale = [
      600 / width,
      900 / height,
      1.0,
    ].reduce((a, b) => a < b ? a : b);
    final resized = await ui.instantiateImageCodec(
      bytes,
      targetWidth: (width * scale).round(),
      targetHeight: (height * scale).round(),
    );
    final resizedFrame = await resized.getNextFrame();
    final data = await resizedFrame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    resizedFrame.image.dispose();
    resized.dispose();
    if (data == null) throw const FormatException('Unreadable image');
    return data.buffer.asUint8List();
  }
}
