import 'package:go_router/go_router.dart';

import '../screens/destination_screen.dart';
import '../screens/home_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const play = '/play';
  static const decks = '/decks';
  static const cards = '/cards';
  static const search = '/search';
  static const journal = '/journal';
  static const aiChat = '/ai-chat';
  static const rules = '/rules';
  static const settings = '/settings';
  static const admin = '/admin';
}

abstract final class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      _placeholder(AppRoutes.play, 'Play'),
      _placeholder(AppRoutes.decks, 'Choose Deck'),
      _placeholder(AppRoutes.cards, 'Browse Cards'),
      _placeholder(AppRoutes.search, 'Search'),
      _placeholder(AppRoutes.journal, 'Journal'),
      _placeholder(AppRoutes.aiChat, 'AI Chat'),
      _placeholder(AppRoutes.rules, 'Rules'),
      _placeholder(AppRoutes.settings, 'Settings'),
      _placeholder(AppRoutes.admin, 'Admin'),
    ],
  );

  static GoRoute _placeholder(String path, String title) {
    return GoRoute(
      path: path,
      builder: (_, _) => DestinationScreen(title: title),
    );
  }
}
