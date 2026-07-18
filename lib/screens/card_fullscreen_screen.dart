import 'package:flutter/material.dart';
import '../models/card_image_model.dart';
import '../widgets/local_card_image.dart';

/// Displays PNG cards full-screen with horizontal swipe and pinch-to-zoom.
class CardFullscreenScreen extends StatelessWidget {
  /// Creates a full-screen card viewer.
  const CardFullscreenScreen({
    required this.cards,
    required this.initialIndex,
    this.useAssetImages = false,
    super.key,
  });

  /// Cards in the current deck.
  final List<CardImageModel> cards;

  /// The first visible card index.
  final int initialIndex;

  /// Whether cards should be read from bundled Flutter assets.
  final bool useAssetImages;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: PageView.builder(
      controller: PageController(initialPage: initialIndex),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: useAssetImages
                ? Image.asset(
                    card.path,
                    fit: BoxFit.contain,
                    errorBuilder: _errorBuilder,
                  )
                : LocalCardImage(
                    path: card.path,
                    fit: BoxFit.contain,
                  ),
          ),
        );
      },
    ),
  );

  static Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) => const Icon(Icons.broken_image_outlined, size: 64);
}
