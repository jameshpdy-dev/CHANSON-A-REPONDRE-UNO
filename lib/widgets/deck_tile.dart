import 'dart:io';
import 'package:flutter/material.dart';
import '../models/deck_model.dart';

/// Displays an imported deck with cover, count, and direct actions.
class DeckTile extends StatelessWidget {
  /// Creates an imported deck tile.
  const DeckTile({
    required this.deck,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  /// The deck displayed by this tile.
  final DeckModel deck;

  /// Opens the deck gallery.
  final VoidCallback onOpen;

  /// Requests deck deletion.
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          height: 108,
          child: deck.cards.isEmpty
              ? const Icon(Icons.style_rounded)
              : Image.file(
                  File(deck.cards.first.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image_outlined),
                ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(deck.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${deck.cards.length} PNG cards'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: onOpen,
                      child: const Text('Open'),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete deck',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
