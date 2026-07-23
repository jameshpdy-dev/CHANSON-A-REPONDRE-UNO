import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/card_item.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_artwork.dart';
import '../widgets/search_card_castle.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  void openFullscreen(CardItem card) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: CardArtwork(card: card, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CardsProvider>();
    final normalized = query.trim().toLowerCase();
    final results = state.cards
        .where((card) {
          if (normalized.isEmpty) return true;
          return [
            card.title,
            card.originalFilename ?? '',
            card.category,
            card.question,
            card.answer,
            card.transcription ?? '',
            ...card.tags,
          ].join(' ').toLowerCase().contains(normalized);
        })
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Search cards',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No matching cards.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SearchCardCastle(
                        cards: results,
                        onOpenFullscreen: openFullscreen,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
