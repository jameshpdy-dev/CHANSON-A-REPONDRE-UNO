import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/deck_model.dart';
import '../services/deck_import_service.dart';
import '../services/deck_storage_service.dart';

/// Provides imported PNG decks and their persistence operations to the UI.
class DeckProvider extends ChangeNotifier {
  /// Creates the deck state controller.
  DeckProvider(this._storage, this._importer);

  final DeckStorageService _storage;
  final DeckImportService _importer;
  List<DeckModel> _decks = const [];
  bool _busy = false;
  String? _error;

  /// The saved imported decks.
  List<DeckModel> get decks => List.unmodifiable(_decks);

  /// Whether a storage operation is active.
  bool get busy => _busy;

  /// The latest user-safe error.
  String? get error => _error;

  /// Restores deck metadata on app startup.
  Future<void> load() async {
    _busy = true;
    notifyListeners();
    try {
      _decks = await _storage.loadDecks();
    } catch (_) {
      _error = 'Imported decks could not be loaded.';
    }
    _busy = false;
    notifyListeners();
  }

  /// Imports selected PNG files as one named deck.
  Future<bool> importDeck(String name, List<PlatformFile> files) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final deck = await _importer.importDeck(deckName: name, files: files);
      _decks = [..._decks, deck];
      await _storage.saveDecks(_decks);
      return true;
    } on FormatException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'The PNG deck could not be imported.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Removes a deck's metadata and copied PNG directory.
  Future<void> deleteDeck(DeckModel deck) async {
    _busy = true;
    notifyListeners();
    try {
      await _storage.deleteDeckFiles(deck.id);
      _decks = _decks
          .where((item) => item.id != deck.id)
          .toList(growable: false);
      await _storage.saveDecks(_decks);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
