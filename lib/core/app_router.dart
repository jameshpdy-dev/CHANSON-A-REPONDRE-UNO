import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/card_browser_screen.dart';
import '../screens/card_viewer_screen.dart';
import '../screens/deck_gallery_screen.dart';
import '../screens/deck_selection_screen.dart';
import '../screens/destination_placeholder_screen.dart';
import '../screens/diagnostics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/png_upload_screen.dart';
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
      GoRoute(
        path: '/diagnostics',
        name: 'diagnostics',
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      ..._destinations.map(
        (destination) => GoRoute(
          path: destination.path,
          name: destination.name,
          builder: (context, state) => DestinationPlaceholderScreen(
            title: destination.title,
            icon: destination.icon,
          ),
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
      '/profile',
      'profile',
      'Profile',
      Icons.person_rounded,
    ),
    _DestinationRoute(
      '/dj-who-videos',
      'dj-who-videos',
      'DJ WHO Videos',
      Icons.graphic_eq_rounded,
    ),
  ];
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
