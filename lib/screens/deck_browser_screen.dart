import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/chanson_a_repondre_uno_deck.dart';
import '../models/deck_summary.dart';
import '../providers/cards_provider.dart';

/// Presents every deck available in the loaded JSON card collection.
class DeckBrowserScreen extends StatelessWidget {
  /// Creates a deck browser screen.
  const DeckBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardsState = context.watch<CardsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Deck'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Home',
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/upload-png'),
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Upload PNG cards',
          ),
        ],
      ),
      body: _DeckBrowserBody(cardsState: cardsState),
    );
  }
}

/// Resolves the deck browser's loading, failure, and collection states.
class _DeckBrowserBody extends StatelessWidget {
  /// Creates the deck browser body.
  const _DeckBrowserBody({required this.cardsState});

  final CardsProvider cardsState;

  @override
  Widget build(BuildContext context) {
    if (cardsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cardsState.errorMessage case final message?) {
      return Center(child: Text(message));
    }

    final decks = DeckSummary.fromCards(cardsState.cards);
    if (decks.isEmpty) {
      return const Center(child: Text('No decks are available yet.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 3
            : 2;
        return MasonryGridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: decks.length,
          itemBuilder: (context, index) => _DeckTile(deck: decks[index]),
        );
      },
    );
  }
}

/// A responsive deck summary tile.
class _DeckTile extends StatelessWidget {
  /// Creates a deck tile.
  const _DeckTile({required this.deck});

  final DeckSummary deck;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/decks/${Uri.encodeComponent(deck.id)}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.style_rounded, color: palette.primary, size: 30),
              const SizedBox(height: 18),
              Text(deck.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('${deck.cardCount} cards'),
              if (deck.id == chansonARepondreUnoDeckId) ...[
                const SizedBox(height: 4),
                Text(
                  'Permanent deck',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: deck.categories
                    .map((category) => Chip(label: Text(category)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
