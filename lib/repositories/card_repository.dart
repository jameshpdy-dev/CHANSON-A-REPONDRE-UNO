import '../models/card_item.dart';

/// Defines the card data operations consumed by application features.
abstract interface class CardRepository {
  /// Loads every card available to the application.
  Future<List<CardItem>> loadCards();
}
