import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/card_item.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_artwork.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CardsProvider>();
    final normalized = query.trim().toLowerCase();
    final results = state.cards
        .where((card) {
          if (normalized.isEmpty) return true;
          return [
            card.title,
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
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          childAspectRatio: .72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        _SearchCard(card: results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.card});
  final CardItem card;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.go('/cards/${Uri.encodeComponent(card.id)}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: CardArtwork(card: card, thumbnail: true)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              card.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
