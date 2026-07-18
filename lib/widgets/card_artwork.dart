import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_item.dart';
import '../providers/cards_provider.dart';

class CardArtwork extends StatelessWidget {
  const CardArtwork({
    required this.card,
    this.thumbnail = false,
    this.fit = BoxFit.cover,
    super.key,
  });
  final CardItem card;
  final bool thumbnail;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (!card.isImported) {
      return card.image.isEmpty
          ? const ColoredBox(color: Color(0xFF483619))
          : Image.asset(
              card.image,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Bundled card asset failed: ${card.image}');
                return const ColoredBox(
                  color: Color(0xFF483619),
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                );
              },
            );
    }
    final reference = thumbnail ? (card.thumbnail ?? card.image) : card.image;
    return FutureBuilder(
      future: context.read<CardsProvider>().readStoredImage(reference),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFF483619),
            child: Center(child: Icon(Icons.broken_image_outlined)),
          );
        }
        return Image.memory(bytes, fit: fit, gaplessPlayback: true);
      },
    );
  }
}
