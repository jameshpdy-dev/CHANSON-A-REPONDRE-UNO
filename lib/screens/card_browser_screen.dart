import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/card_item.dart';
import '../providers/cards_provider.dart';

/// Shows the cards loaded from JSON, optionally limited to a selected deck.
class CardBrowserScreen extends StatelessWidget {
  /// Creates a card browser.
  const CardBrowserScreen({this.deckId, super.key});

  /// An optional deck identifier used to filter the collection.
  final String? deckId;

  @override
  Widget build(BuildContext context) {
    final cardState = context.watch<CardsProvider>();
    final cards = cardState.cards
        .where((card) => deckId == null || card.deckId == deckId)
        .toList(growable: false);
    final title = deckId == null ? 'Browse Cards' : _formatDeckName(deckId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => context.go(deckId == null ? '/' : '/decks'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: _buildBody(cards, cardState),
    );
  }

  Widget _buildBody(List<CardItem> cards, CardsProvider cardState) {
    if (cardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cardState.errorMessage case final String message) {
      return Center(child: Text(message));
    }
    if (cards.isEmpty) {
      return const Center(child: Text('No cards match this deck.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _CardListTile(card: cards[index]),
    );
  }

  static String _formatDeckName(String id) {
    return id
        .split(RegExp('[-_]'))
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

/// A concise visual entry point into a card viewer.
class _CardListTile extends StatelessWidget {
  /// Creates a card list tile.
  const _CardListTile({required this.card});

  final CardItem card;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.go('/cards/${Uri.encodeComponent(card.id)}'),
        leading: _CategorySwatch(colour: card.colour),
        title: Text(card.title),
        subtitle: Text(
          card.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: card.favorite
            ? const Icon(Icons.favorite_rounded, color: Color(0xFFD5A53C))
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// Displays the matching colour associated with a card category.
class _CategorySwatch extends StatelessWidget {
  /// Creates a category swatch.
  const _CategorySwatch({required this.colour});

  final String colour;

  @override
  Widget build(BuildContext context) {
    const colours = <String, Color>{
      'red': Color(0xFFA52D20),
      'yellow': Color(0xFFC79322),
      'green': Color(0xFF4B792E),
      'blue': Color(0xFF265F8F),
      'black': Color(0xFF17130E),
    };
    return CircleAvatar(backgroundColor: colours[colour] ?? const Color(0xFF8A6428));
  }
}
