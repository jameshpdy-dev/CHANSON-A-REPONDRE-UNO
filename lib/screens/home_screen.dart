import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Displays the poster-led landing page with responsive, invisible hotspots.
class HomeScreen extends StatelessWidget {
  /// Creates the application home screen.
  const HomeScreen({super.key});

  static const _posterSize = Size(1440, 2560);

  static const _hotspots = <_PosterHotspot>[
    _PosterHotspot('Play', '/play', Rect.fromLTWH(772, 111, 92, 110)),
    _PosterHotspot('Choose Deck', '/decks', Rect.fromLTWH(883, 111, 92, 110)),
    _PosterHotspot('Browse Cards', '/cards', Rect.fromLTWH(1108, 111, 92, 110)),
    _PosterHotspot('Journal', '/journal', Rect.fromLTWH(1320, 111, 92, 110)),
    _PosterHotspot('Settings', '/settings', Rect.fromLTWH(1320, 230, 92, 110)),
    _PosterHotspot('Rules', '/rules', Rect.fromLTWH(1214, 111, 92, 110)),
    _PosterHotspot('AI Chat', '/ai-chat', Rect.fromLTWH(320, 1620, 215, 220)),
    _PosterHotspot('Search', '/search', Rect.fromLTWH(42, 2200, 285, 150)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _posterSize.width,
              height: _posterSize.height,
              child: Image.asset(
                'assets/images/home_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const ColoredBox(color: Color(0x4D000000)),
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _posterSize.width,
              height: _posterSize.height,
              child: Stack(
                children: _hotspots
                    .map(
                      (hotspot) => Positioned.fromRect(
                        rect: hotspot.bounds,
                        child: Semantics(
                          button: true,
                          label: hotspot.label,
                          child: Tooltip(
                            message: hotspot.label,
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () => context.go(hotspot.path),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Defines a scalable interactive region on the source poster.
class _PosterHotspot {
  /// Creates a poster hotspot.
  const _PosterHotspot(this.label, this.path, this.bounds);

  /// The accessible destination name.
  final String label;

  /// The destination path.
  final String path;

  /// The hotspot bounds in the poster's original coordinate space.
  final Rect bounds;
}
