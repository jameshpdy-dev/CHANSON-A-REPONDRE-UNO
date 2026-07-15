import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import 'card_fullscreen_screen.dart';

/// Shows one imported deck's PNG cards in a responsive grid.
class DeckGalleryScreen extends StatelessWidget {
  /// Creates a gallery for a deck identifier.
  const DeckGalleryScreen({required this.deckId, super.key});

  /// The selected deck identifier.
  final String deckId;
  @override
  Widget build(BuildContext context) {
    final deck = context
        .watch<DeckProvider>()
        .decks
        .where((item) => item.id == deckId)
        .cast<dynamic>()
        .firstOrNull;
    if (deck == null) {
      return const Scaffold(body: Center(child: Text('Deck not found.')));
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
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.file(File(card.path), fit: BoxFit.cover),
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
