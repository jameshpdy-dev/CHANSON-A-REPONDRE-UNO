import 'package:flutter/material.dart';

class EmptyDeckState extends StatelessWidget {
  const EmptyDeckState({
    required this.title,
    required this.message,
    required this.onChooseDeck,
    super.key,
  });
  final String title;
  final String message;
  final VoidCallback onChooseDeck;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style_outlined, size: 58),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onChooseDeck,
            icon: const Icon(Icons.style),
            label: const Text('Choose Deck'),
          ),
        ],
      ),
    ),
  );
}
