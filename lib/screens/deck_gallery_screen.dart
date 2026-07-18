import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/chanson_a_repondre_uno_deck.dart';
import '../models/card_item.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_artwork.dart';

/// Shows one deck's cards from the shared card library in a responsive grid.
class DeckGalleryScreen extends StatelessWidget {
  /// Creates a gallery for a deck identifier.
  const DeckGalleryScreen({required this.deckId, super.key});

  /// The selected deck identifier.
  final String deckId;

  @override
  Widget build(BuildContext context) {
    final cardsState = context.watch<CardsProvider>();
    final cards = cardsState.cards
        .where((card) => card.deckId == deckId)
        .toList(growable: false);
    final title = deckId == chansonARepondreUnoDeckId
        ? chansonARepondreUnoDeckName
        : _formatDeckName(deckId);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => context.go('/decks'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Choose Deck',
        ),
      ),
      body: _DeckGalleryBody(cardsState: cardsState, cards: cards),
    );
  }

  static String _formatDeckName(String id) => id
      .split(RegExp('[-_]'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _DeckGalleryBody extends StatelessWidget {
  const _DeckGalleryBody({required this.cardsState, required this.cards});

  final CardsProvider cardsState;
  final List<CardItem> cards;

  @override
  Widget build(BuildContext context) {
    if (cardsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cardsState.errorMessage case final String message) {
      return Center(child: Text(message));
    }
    if (cards.isEmpty) {
      return const Center(child: Text('No cards match this deck.'));
    }

    return LayoutBuilder(
      builder: (context, size) {
        final count = size.maxWidth >= 1000
            ? 5
            : size.maxWidth >= 650
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .72,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    context.go('/cards/${Uri.encodeComponent(card.id)}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CardArtwork(
                        card: card,
                        thumbnail: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        card.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
