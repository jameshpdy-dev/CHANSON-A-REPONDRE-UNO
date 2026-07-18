import 'package:flutter/foundation.dart';

import '../models/card_set.dart';
import '../models/card_set_import_source.dart';
import '../repositories/card_set_repository.dart';

/// Owns persisted imported card sets and their loading state.
class CardSetsProvider extends ChangeNotifier {
  /// Creates the imported-card-set state controller.
  CardSetsProvider(this._repository);

  final CardSetRepository _repository;
  List<CardSet> _sets = const [];
  bool _isLoading = false;
  String? _error;

  /// The available imported card sets.
  List<CardSet> get sets => List.unmodifiable(_sets);

  /// Whether a load or import is in progress.
  bool get isLoading => _isLoading;

  /// The latest display-safe failure message.
  String? get error => _error;

  /// Restores imported sets from local storage.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sets = await _repository.loadCardSets();
    } catch (_) {
      _error = 'Imported decks could not be loaded.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Imports PNG sources under a new deck name.
  Future<bool> importSet(
    String deckName,
    List<CardSetImportSource> sources,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final set = await _repository.importPngCardSet(
        deckName: deckName,
        sources: sources,
      );
      _sets = [..._sets, set];
      return true;
    } on FormatException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'The PNG deck could not be imported.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
