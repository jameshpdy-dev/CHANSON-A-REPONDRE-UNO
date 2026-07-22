import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../widgets/deck_tile.dart';
import '../widgets/home_navigation_button.dart';

class DeckSelectionScreen extends StatelessWidget {
  const DeckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeckProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Deck'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: HomeNavigationButton(),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.decks.isEmpty
          ? const Center(child: Text('The permanent deck is loading.'))
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 4
                    : constraints.maxWidth >= 650
                    ? 3
                    : constraints.maxWidth >= 420
                    ? 2
                    : 1;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: provider.decks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final deck = provider.decks[index];
                    return DeckTile(
                      deck: deck,
                      selected: deck.id == provider.activeDeckId,
                      onSelect: () => provider.select(deck.id),
                    );
                  },
                );
              },
            ),
    );
  }
}
