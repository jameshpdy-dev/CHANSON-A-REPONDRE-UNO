import 'package:flutter/foundation.dart';

import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../repositories/card_repository.dart';

enum CatalogStatus { idle, loading, ready, error }

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CardRepository _repository;
  CatalogStatus _status = CatalogStatus.idle;
  List<Deck> _decks = const [];
  List<ChansonCard> _cards = const [];
  Object? _error;

  CatalogStatus get status => _status;
  List<Deck> get decks => List.unmodifiable(_decks);
  List<ChansonCard> get cards => List.unmodifiable(_cards);
  Object? get error => _error;

  Future<void> load() async {
    _status = CatalogStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final catalog = await _repository.load();
      _decks = catalog.decks;
      _cards = catalog.cards;
      _status = CatalogStatus.ready;
    } on Object catch (error) {
      _error = error;
      _status = CatalogStatus.error;
    }
    notifyListeners();
  }

  List<ChansonCard> cardsForDeck(String deckId) {
    return _cards.where((card) => card.deckId == deckId).toList();
  }

  ChansonCard? cardById(String id) {
    for (final card in _cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  void toggleFavorite(String id) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index < 0) return;
    _cards = List.of(_cards)
      ..[index] = _cards[index].copyWith(favorite: !_cards[index].favorite);
    notifyListeners();
  }
}
