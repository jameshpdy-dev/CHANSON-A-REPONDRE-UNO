import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/chanson_a_repondre_uno_deck.dart';
import '../models/card_item.dart';
import '../providers/cards_provider.dart';
import '../repositories/card_repository.dart';
import '../widgets/card_artwork.dart';

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
        actions: [
          if (deckId == null)
            IconButton(
              onPressed: cardState.isImporting
                  ? null
                  : () => _importCards(context, cardState),
              icon: const Icon(Icons.upload_file_rounded),
              tooltip: 'Import Cards',
            ),
          if (deckId == null && cardState.importedCount > 0)
            PopupMenuButton(
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'clear',
                  child: Text('Delete all imported cards'),
                ),
              ],
              onSelected: (_) => _clearImported(context, cardState),
            ),
        ],
      ),
      body: Column(
        children: [
          if (deckId == null)
            ListTile(
              title: Text(
                '${cardState.importedCount} / $maxStoredCards cards stored',
              ),
              subtitle: cardState.isImporting
                  ? Text(
                      'Importing ${cardState.importCompleted} '
                      'of ${cardState.importTotal}…',
                    )
                  : null,
              trailing: FilledButton.icon(
                onPressed: cardState.isImporting
                    ? null
                    : () => _importCards(context, cardState),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Import Cards'),
              ),
            ),
          Expanded(child: _buildBody(cards, cardState)),
        ],
      ),
    );
  }

  Future<void> _importCards(BuildContext context, CardsProvider state) async {
    final remaining = maxStoredCards - state.importedCount;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The 100-card limit has been reached.')),
      );
      return;
    }
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (picked == null || !context.mounted) return;
    var files = picked.files;
    if (files.length > remaining) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not enough card slots'),
          content: Text(
            'Only $remaining of ${files.length} selected cards fit. '
            'Import the first $remaining?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
      files = files.take(remaining).toList();
    }
    final candidates = files
        .map(
          (file) => CardImportCandidate(
            filename: file.name,
            bytes: file.bytes ?? Uint8List(0),
            mimeType: _mimeFor(file.extension?.toLowerCase()),
          ),
        )
        .toList();
    final result = await state.importCards(candidates);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Import complete: ${result.imported} imported, '
          '${result.duplicates} duplicates, '
          '${result.invalid + result.unsupported + result.tooLarge + result.errors} skipped.',
        ),
      ),
    );
  }

  Future<void> _clearImported(BuildContext context, CardsProvider state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all imported cards?'),
        content: Text(
          'This permanently deletes ${state.importedCount} imported cards. '
          'Bundled cards will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (confirmed == true) await state.clearImportedCards();
  }

  static String? _mimeFor(String? extension) => switch (extension) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    _ => null,
  };

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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _CardListTile(card: cards[index]),
    );
  }

  static String _formatDeckName(String id) {
    if (id == chansonARepondreUnoDeckId) {
      return chansonARepondreUnoDeckName;
    }
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/cards/${Uri.encodeComponent(card.id)}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  card.image.isEmpty
                      ? _CategorySwatch(colour: card.colour)
                      : CardArtwork(
                          card: card,
                          thumbnail: true,
                          fit: BoxFit.contain,
                        ),
                  if (card.isImported)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete imported card',
                        onPressed: () => _delete(context),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.isImported ? 'Imported card' : card.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete imported card?'),
        content: Text('Permanently delete “${card.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CardsProvider>().deleteImportedCard(card.id);
    }
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
    return CircleAvatar(
      backgroundColor: colours[colour] ?? const Color(0xFF8A6428),
    );
  }
}
