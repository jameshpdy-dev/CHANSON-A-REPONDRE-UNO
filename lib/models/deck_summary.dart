import 'card_item.dart';
import '../data/chanson_a_repondre_uno_deck.dart';

/// Summarizes a deck derived from the currently loaded card collection.
class DeckSummary {
  /// Creates a deck summary.
  const DeckSummary({
    required this.id,
    required this.title,
    required this.cardCount,
    required this.categories,
  });

  /// Builds deck summaries grouped from a card collection.
  static List<DeckSummary> fromCards(List<CardItem> cards) {
    final groupedCards = <String, List<CardItem>>{};
    for (final card in cards) {
      groupedCards.putIfAbsent(card.deckId, () => []).add(card);
    }

    return groupedCards.entries
        .map(
          (entry) => DeckSummary(
            id: entry.key,
            title: _formatTitle(entry.key),
            cardCount: entry.value.length,
            categories: entry.value.map((card) => card.category).toSet(),
          ),
        )
        .toList(growable: false);
  }

  static String _formatTitle(String id) {
    if (id == chansonARepondreUnoDeckId) {
      return chansonARepondreUnoDeckName;
    }
    return id
        .split(RegExp('[-_]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  /// The persistent deck identifier.
  final String id;

  /// The human-readable deck title.
  final String title;

  /// The number of cards currently in the deck.
  final int cardCount;

  /// Categories represented by the deck's cards.
  final Set<String> categories;
}
