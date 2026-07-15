import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/card_item.dart';
import '../providers/cards_provider.dart';

/// Shows a swipeable, media-capable detail view for a selected card.
class CardViewerScreen extends StatefulWidget {
  /// Creates a card viewer for a stable card identifier.
  const CardViewerScreen({required this.cardId, super.key});

  /// The identifier of the initially selected card.
  final String cardId;

  @override
  State<CardViewerScreen> createState() => _CardViewerScreenState();
}

/// Maintains swipe position and optional audio/video playback controllers.
class _CardViewerScreenState extends State<CardViewerScreen> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  String? _activeMediaCardId;

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsProvider>().cards;
    final initialIndex = cards.indexWhere((card) => card.id == widget.cardId);
    if (initialIndex < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This card is no longer available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/cards'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Browse cards',
        ),
        title: const Text('Card Viewer'),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: cards.length,
        itemBuilder: (context, index) => _CardPage(
          card: cards[index],
          isMediaActive: _activeMediaCardId == cards[index].id,
          videoController: _videoController,
          onToggleFavorite: () => _toggleFavorite(cards[index]),
          onPlayAudio: () => _playAudio(cards[index]),
          onPlayVideo: () => _playVideo(cards[index]),
        ),
      ),
    );
  }

  void _toggleFavorite(CardItem card) {
    context.read<CardsProvider>().updateCard(card.copyWith(favorite: !card.favorite));
  }

  Future<void> _playAudio(CardItem card) async {
    if (card.audio.isEmpty) {
      return;
    }
    _audioPlayer ??= AudioPlayer();
    await _audioPlayer!.play(AssetSource(card.audio));
  }

  Future<void> _playVideo(CardItem card) async {
    if (card.video.isEmpty) {
      return;
    }
    await _videoController?.dispose();
    final controller = VideoPlayerController.asset(card.video);
    setState(() {
      _activeMediaCardId = card.id;
      _videoController = controller;
    });
    await controller.initialize();
    await controller.play();
    if (mounted) {
      setState(() {});
    }
  }
}

/// Renders the content and actions for one card in the swipe viewer.
class _CardPage extends StatelessWidget {
  /// Creates a card page.
  const _CardPage({
    required this.card,
    required this.isMediaActive,
    required this.videoController,
    required this.onToggleFavorite,
    required this.onPlayAudio,
    required this.onPlayVideo,
  });

  final CardItem card;
  final bool isMediaActive;
  final VideoPlayerController? videoController;
  final VoidCallback onToggleFavorite;
  final VoidCallback onPlayAudio;
  final VoidCallback onPlayVideo;

  @override
  Widget build(BuildContext context) {
    final hasActiveVideo = isMediaActive && (videoController?.value.isInitialized ?? false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasActiveVideo)
                    AspectRatio(
                      aspectRatio: videoController!.value.aspectRatio,
                      child: VideoPlayer(videoController!),
                    )
                  else if (card.image.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(card.image, fit: BoxFit.cover),
                    )
                  else
                    const _CardArtworkPlaceholder(),
                  const SizedBox(height: 24),
                  Text(card.category.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(card.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Text(card.question, style: Theme.of(context).textTheme.titleLarge),
                  if (card.quote.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('"${card.quote}"', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    Text(card.author, style: Theme.of(context).textTheme.labelLarge),
                  ],
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: const Text('Reveal answer'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(card.answer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IconButton.filledTonal(
                        onPressed: onToggleFavorite,
                        tooltip: card.favorite ? 'Remove favourite' : 'Add favourite',
                        icon: Icon(card.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: card.audio.isEmpty ? null : onPlayAudio,
                        tooltip: 'Play audio',
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: card.video.isEmpty ? null : onPlayVideo,
                        tooltip: 'Play video',
                        icon: const Icon(Icons.play_circle_outline_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides a graceful artwork surface when a card has no image asset.
class _CardArtworkPlaceholder extends StatelessWidget {
  /// Creates an artwork placeholder.
  const _CardArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ColoredBox(
        color: const Color(0xFF483619),
        child: Center(
          child: Icon(Icons.style_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
