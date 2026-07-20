import 'card_model.dart';
import 'deck_model.dart';

class CardCatalog {
  const CardCatalog({required this.decks, required this.cards});

  final List<Deck> decks;
  final List<ChansonCard> cards;
}
