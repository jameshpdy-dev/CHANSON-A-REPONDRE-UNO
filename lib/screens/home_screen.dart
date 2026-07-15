import 'package:flutter/material.dart';

import '../widgets/menu_button.dart';

/// Displays the poster-led landing experience and primary application actions.
class HomeScreen extends StatelessWidget {
  /// Creates the application home screen.
  const HomeScreen({super.key});

  static const _actions = <_HomeAction>[
    _HomeAction('Play', Icons.play_arrow_rounded),
    _HomeAction('Choose Deck', Icons.style_rounded),
    _HomeAction('Browse Cards', Icons.auto_stories_rounded),
    _HomeAction('Search', Icons.search_rounded),
    _HomeAction('Journal', Icons.menu_book_rounded),
    _HomeAction('AI Chat', Icons.smart_toy_rounded),
    _HomeAction('Rules', Icons.gavel_rounded),
    _HomeAction('Settings', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFF120E09),
            ),
          ),
          const ColoredBox(color: Color(0x4D000000)),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 620;
                final buttonWidth = isCompact
                    ? (constraints.maxWidth - 12) / 2
                    : 310.0;

                return Align(
                  alignment:
                      isCompact ? Alignment.bottomCenter : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? constraints.maxWidth : 350,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xCC120E09),
                        border: Border.all(
                          color: const Color(0xFFB8862E).withValues(alpha: 0.8),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHOOSE YOUR PATH',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _actions
                                  .map(
                                    (action) => SizedBox(
                                      width: isCompact ? buttonWidth : 318,
                                      child: MenuButton(
                                        icon: action.icon,
                                        label: action.label,
                                        onPressed: () => _showUnavailableMessage(
                                          context,
                                          action.label,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUnavailableMessage(BuildContext context, String destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$destination is coming next.')),
    );
  }
}

/// Describes one destination presented in the home menu.
class _HomeAction {
  /// Creates a home-menu destination descriptor.
  const _HomeAction(this.label, this.icon);

  /// The menu label.
  final String label;

  /// The menu icon.
  final IconData icon;
}
