import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_image_model.dart';

/// Displays PNG cards full-screen with horizontal swipe and pinch-to-zoom.
class CardFullscreenScreen extends StatelessWidget {
  /// Creates a full-screen card viewer.
  const CardFullscreenScreen({
    required this.cards,
    required this.initialIndex,
    super.key,
  });

  /// Cards in the current deck.
  final List<CardImageModel> cards;

  /// The first visible card index.
  final int initialIndex;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: PageView.builder(
      controller: PageController(initialPage: initialIndex),
      itemCount: cards.length,
      itemBuilder: (context, index) => InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.file(File(cards[index].path), fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
