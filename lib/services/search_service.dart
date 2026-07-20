import '../models/card_image_model.dart';
import '../models/deck_model.dart';

class SearchService {
  List<CardImageModel> cards({
    required List<Deck> decks,
    String query = '',
    String? deckId,
    String? category,
    String? colour,
  }) {
    final needle = query.trim().toLowerCase();
    return decks.expand((deck) => deck.cards).where((card) {
      final haystack = [
        card.title,
        card.path,
        card.author,
        card.theme,
        card.emotion,
        card.category,
        card.colour,
        card.year?.toString() ?? '',
        ...card.tags,
      ].join(' ').toLowerCase();
      return (needle.isEmpty || haystack.contains(needle)) &&
          (deckId == null || card.deckId == deckId) &&
          (category == null || card.category == category) &&
          (colour == null || card.colour == colour);
    }).toList();
  }

  List<Deck> decks(List<Deck> decks, String query) {
    final needle = query.trim().toLowerCase();
    return decks
        .where((deck) => deck.name.toLowerCase().contains(needle))
        .toList();
  }
}
