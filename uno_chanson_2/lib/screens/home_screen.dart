import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_router.dart';
import '../widgets/background_shell.dart';
import '../widgets/responsive_hotspot.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _sourceSize = Size(1250, 686);
  static const _items = <({String label, String route, Rect rect})>[
    (label: 'Play', route: AppRoutes.play, rect: Rect.fromLTWH(907, 116, 317, 51)),
    (label: 'Choose Deck', route: AppRoutes.decks, rect: Rect.fromLTWH(907, 180, 317, 51)),
    (label: 'Browse Cards', route: AppRoutes.cards, rect: Rect.fromLTWH(907, 244, 317, 51)),
    (label: 'Search', route: AppRoutes.search, rect: Rect.fromLTWH(907, 308, 317, 51)),
    (label: 'Journal', route: AppRoutes.journal, rect: Rect.fromLTWH(907, 372, 317, 51)),
    (label: 'AI Chat', route: AppRoutes.aiChat, rect: Rect.fromLTWH(907, 436, 317, 51)),
    (label: 'Rules', route: AppRoutes.rules, rect: Rect.fromLTWH(907, 500, 317, 51)),
    (label: 'Settings', route: AppRoutes.settings, rect: Rect.fromLTWH(907, 564, 317, 51)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final alignment = size.aspectRatio < 1
              ? Alignment.topRight
              : Alignment.center;

          return BackgroundShell(
            alignment: alignment,
            child: Stack(
              children: [
                for (final item in _items)
                  ResponsiveHotspot(
                    label: item.label,
                    sourceRect: item.rect,
                    sourceSize: _sourceSize,
                    viewportSize: size,
                    imageAlignment: alignment,
                    onTap: () => context.go(item.route),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
