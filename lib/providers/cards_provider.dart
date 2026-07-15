import 'package:flutter/foundation.dart';

import '../models/card_item.dart';
import '../repositories/card_repository.dart';

/// Exposes the JSON card collection and its asynchronous loading state.
class CardsProvider extends ChangeNotifier {
  /// Creates a cards state controller.
  CardsProvider(this._repository);

  final CardRepository _repository;
  List<CardItem> _cards = const [];
  bool _isLoading = false;
  String? _errorMessage;

  /// The currently loaded card collection.
  List<CardItem> get cards => List.unmodifiable(_cards);

  /// Whether the initial load is in progress.
  bool get isLoading => _isLoading;

  /// A display-safe error message when loading fails.
  String? get errorMessage => _errorMessage;

  /// Loads cards from the configured repository.
  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _repository.loadCards();
    } on FormatException {
      _errorMessage = 'The card collection could not be read.';
    } catch (_) {
      _errorMessage = 'The card collection could not be loaded.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Replaces a card while retaining the source collection order.
  void updateCard(CardItem updatedCard) {
    _cards = _cards
        .map((card) => card.id == updatedCard.id ? updatedCard : card)
        .toList(growable: false);
    notifyListeners();
  }
}
