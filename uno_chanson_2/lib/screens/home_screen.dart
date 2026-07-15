import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/menu_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _menuItems = <({String label, IconData icon})>[
    (label: 'Play', icon: Icons.play_arrow_rounded),
    (label: 'Choose Deck', icon: Icons.style_rounded),
    (label: 'Browse Cards', icon: Icons.menu_book_rounded),
    (label: 'Search', icon: Icons.search_rounded),
    (label: 'Journal', icon: Icons.library_books_rounded),
    (label: 'AI Chat', icon: Icons.smart_toy_rounded),
    (label: 'Rules', icon: Icons.gavel_rounded),
    (label: 'Settings', icon: Icons.settings_rounded),
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
            alignment: Alignment.center,
          ),
          const ColoredBox(color: Color(0x4D000000)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                return Align(
                  alignment: compact ? Alignment.center : Alignment.centerRight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 20 : 32,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 440 : 370,
                        minWidth: 0,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xD9100D08),
                          border: Border.all(color: AppTheme.gold),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x99000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(compact ? 16 : 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'CHOOSE YOUR PATH',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 14),
                              for (var index = 0;
                                  index < _menuItems.length;
                                  index++) ...[
                                MenuButton(
                                  label: _menuItems[index].label,
                                  icon: _menuItems[index].icon,
                                  onPressed: () => _showComingSoon(
                                    context,
                                    _menuItems[index].label,
                                  ),
                                ),
                                if (index != _menuItems.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
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

  void _showComingSoon(BuildContext context, String destination) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$destination coming soon')));
  }
}
