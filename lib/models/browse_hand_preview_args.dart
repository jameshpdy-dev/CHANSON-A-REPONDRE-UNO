import 'card_image_model.dart';

class BrowseHandPreviewArgs {
  BrowseHandPreviewArgs({
    required List<CardImageModel> cards,
    required int initialIndex,
    required this.deckId,
    required this.deckName,
    this.selectedCardId,
  }) : cards = List.unmodifiable(cards),
       initialIndex = cards.isEmpty
           ? 0
           : initialIndex.clamp(0, cards.length - 1) {
    if (cards.map((card) => card.id).toSet().length != cards.length) {
      throw ArgumentError('Preview card IDs must be unique.');
    }
  }

  final List<CardImageModel> cards;
  final int initialIndex;
  final String deckId;
  final String deckName;
  final String? selectedCardId;
}
