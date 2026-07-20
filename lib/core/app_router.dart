import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/card_browser_screen.dart';
import '../screens/card_viewer_screen.dart';
import '../screens/png_upload_screen.dart';
import '../screens/deck_gallery_screen.dart';
import '../screens/deck_selection_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';

/// Owns the application's declarative navigation graph.
abstract final class AppRouter {
  /// The router used by the root Material application.
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/cards',
        name: 'cards',
        builder: (context, state) =>
            CardBrowserScreen(deckId: state.uri.queryParameters['deck']),
      ),
      GoRoute(
        path: '/cards/:cardId',
        name: 'card-viewer',
        builder: (context, state) =>
            CardViewerScreen(cardId: state.pathParameters['cardId']!),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/upload-png',
        name: 'upload-png',
        builder: (context, state) => const PngUploadScreen(),
      ),
      GoRoute(
        path: '/decks',
        name: 'decks',
        builder: (context, state) => const DeckSelectionScreen(),
      ),
      GoRoute(
        path: '/decks/:deckId',
        name: 'deck-gallery',
        builder: (context, state) =>
            DeckGalleryScreen(deckId: state.pathParameters['deckId']!),
      ),
      ..._destinations.map(
        (destination) => GoRoute(
          path: destination.path,
          name: destination.name,
          builder: (context, state) =>
              _DestinationScreen(destination: destination),
        ),
      ),
    ],
  );

  static const List<_DestinationRoute> _destinations = [
    _DestinationRoute('/play', 'play', 'Play', Icons.play_arrow_rounded),
    _DestinationRoute(
      '/journal',
      'journal',
      'Journal',
      Icons.menu_book_rounded,
    ),
    _DestinationRoute(
      '/ai-chat',
      'ai-chat',
      'AI Chat',
      Icons.smart_toy_rounded,
    ),
    _DestinationRoute('/rules', 'rules', 'Rules', Icons.gavel_rounded),
    _DestinationRoute(
      '/settings',
      'settings',
      'Settings',
      Icons.settings_rounded,
    ),
    _DestinationRoute(
      '/credits',
      'credits',
      'Credits',
      Icons.favorite_rounded,
    ),
  ];
}

/// A functional destination page for menu features that are not standalone
/// complex flows in the lightweight root app.
class _DestinationScreen extends StatelessWidget {
  const _DestinationScreen({required this.destination});

  final _DestinationRoute destination;

  @override
  Widget build(BuildContext context) {
    final actions = switch (destination.name) {
      'play' => const [
          _DestinationAction('Choose a deck', '/decks', Icons.style_rounded),
          _DestinationAction('Browse cards', '/cards', Icons.menu_book_rounded),
        ],
      'journal' => const [
          _DestinationAction('Browse cards', '/cards', Icons.menu_book_rounded),
          _DestinationAction('Search cards', '/search', Icons.search_rounded),
        ],
      'ai-chat' => const [
          _DestinationAction('Search cards', '/search', Icons.search_rounded),
          _DestinationAction('Browse cards', '/cards', Icons.menu_book_rounded),
        ],
      'rules' => const [
          _DestinationAction('Start from cards', '/cards', Icons.play_arrow_rounded),
          _DestinationAction('Choose deck', '/decks', Icons.style_rounded),
        ],
      'settings' => const [
          _DestinationAction('Import cards', '/cards', Icons.upload_file_rounded),
          _DestinationAction('Import PNG deck', '/decks', Icons.folder_rounded),
        ],
      _ => const [
          _DestinationAction('Home', '/', Icons.home_rounded),
          _DestinationAction('Browse cards', '/cards', Icons.menu_book_rounded),
        ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Home',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(destination.icon, size: 72),
          const SizedBox(height: 16),
          Text(
            _descriptionFor(destination.name),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.icon(
                onPressed: () => context.go(action.path),
                icon: Icon(action.icon),
                label: Text(action.label),
              ),
            ),
        ],
      ),
    );
  }

  static String _descriptionFor(String name) => switch (name) {
        'play' => 'Pick a deck or browse cards to begin a playable session.',
        'journal' => 'Use cards as prompts, then return here from the menu.',
        'ai-chat' => 'Search and open a card before discussing it with AI tools.',
        'rules' => 'Explore the deck, select a card, and answer in turn.',
        'settings' => 'Manage imported cards and PNG decks from the actions below.',
        _ => 'CHANSON À RÉPONDRE UNO — active card library.',
      };
}

class _DestinationAction {
  const _DestinationAction(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}

/// Describes a temporary route while its feature screen is being implemented.
class _DestinationRoute {
  /// Creates a route descriptor.
  const _DestinationRoute(this.path, this.name, this.title, this.icon);

  /// The URL path.
  final String path;

  /// The route's named-navigation identifier.
  final String name;

  /// The page title.
  final String title;

  /// The page's leading icon.
  final IconData icon;
}
