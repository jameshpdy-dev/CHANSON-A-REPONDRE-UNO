import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck_model.dart';

/// Persists deck metadata and manages the PNG deck directory tree.
class DeckStorageService {
  /// Creates a native application-storage service.
  const DeckStorageService();

  static const _metadataKey = 'imported_png_decks';

  /// Returns the requested Documents/decks storage root.
  Future<Directory> decksDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${documents.path}${Platform.pathSeparator}chanson_repondre${Platform.pathSeparator}decks',
    );
    await directory.create(recursive: true);
    return directory;
  }

  /// Restores every saved deck descriptor.
  Future<List<DeckModel>> loadDecks() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(_metadataKey);
    if (source == null) return const [];
    try {
      final decoded = jsonDecode(source) as List<dynamic>;
      return decoded
          .map((item) => DeckModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  /// Saves the complete deck metadata index.
  Future<void> saveDecks(List<DeckModel> decks) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _metadataKey,
      jsonEncode(decks.map((deck) => deck.toJson()).toList()),
    );
  }

  /// Deletes a copied deck directory and its files.
  Future<void> deleteDeckFiles(String deckId) async {
    final root = await decksDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}$deckId');
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
