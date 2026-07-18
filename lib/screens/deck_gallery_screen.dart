import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../widgets/local_card_image.dart';
import 'card_fullscreen_screen.dart';

/// Shows one imported deck's PNG cards in a responsive grid.
class DeckGalleryScreen extends StatelessWidget {
  /// Creates a gallery for a deck identifier.
  const DeckGalleryScreen({required this.deckId, super.key});

  /// The selected deck identifier.
  final String deckId;

  @override
  Widget build(BuildContext context) {
    final decks = context.watch<DeckProvider>().decks;
    final deckIndex = decks.indexWhere((item) => item.id == deckId);
    final deck = deckIndex == -1 ? null : decks[deckIndex];
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This imported deck is unavailable.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(deck.name)),
      body: LayoutBuilder(
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
            itemCount: deck.cards.length,
            itemBuilder: (context, index) {
              final card = deck.cards[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => CardFullscreenScreen(
                        cards: deck.cards,
                        initialIndex: index,
                        useAssetImages: deck.isBundled,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: deck.isBundled
                            ? Image.asset(
                                card.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                              )
                            : LocalCardImage(
                                path: card.path,
                                fit: BoxFit.cover,
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
      ),
    );
  }
}
