import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Displays the poster-led landing page with a visible path menu overlay.
class HomeScreen extends StatefulWidget {
  /// Creates the application home screen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _items = <_PathItem>[
    _PathItem('Play', '/play', Icons.play_arrow_rounded),
    _PathItem('Choose Deck', '/decks', Icons.style_rounded),
    _PathItem('Browse Cards', '/cards', Icons.menu_book_rounded),
    _PathItem('Search', '/search', Icons.search_rounded),
    _PathItem('Journal', '/journal', Icons.book_rounded),
    _PathItem('AI Chat', '/ai-chat', Icons.smart_toy_rounded),
    _PathItem('Rules', '/rules', Icons.gavel_rounded),
    _PathItem('Settings', '/settings', Icons.settings_rounded),
  ];

  static const _gold = Color(0xFFEBC36B);

  final FocusNode _focusNode = FocusNode(debugLabel: 'home-menu');
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _moveSelection(int delta) {
    setState(() {
      _activeIndex = (_activeIndex + delta) % _items.length;
      if (_activeIndex < 0) _activeIndex += _items.length;
    });
  }

  void _activateSelection() {
    context.go(_items[_activeIndex].path);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final panelWidth = width < 700 ? width * 0.88 : 340.0;

    return Scaffold(
      body: FocusableActionDetector(
        focusNode: _focusNode,
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.arrowDown): const _MoveIntent(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): const _MoveIntent(-1),
          const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (intent) {
              _moveSelection(intent.delta);
              return null;
            },
          ),
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _activateSelection();
              return null;
            },
          ),
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/home_background.png', fit: BoxFit.cover),
            const ColoredBox(color: Color(0x73000000)),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: panelWidth,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xD10E0B0D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withAlpha(160)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CHOOSE YOUR PATH',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (var i = 0; i < _items.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PathButton(
                                  item: _items[i],
                                  isActive: i == _activeIndex,
                                  onHover: () =>
                                      setState(() => _activeIndex = i),
                                  onTap: () {
                                    setState(() => _activeIndex = i);
                                    context.go(_items[i].path);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);

  final int delta;
}

class _PathItem {
  const _PathItem(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}

class _PathButton extends StatefulWidget {
  const _PathButton({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.onHover,
  });

  final _PathItem item;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<_PathButton> createState() => _PathButtonState();
}

class _PathButtonState extends State<_PathButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const gold = _HomeScreenState._gold;
    final bg = widget.isActive
        ? const Color(0xCC8A2A33)
        : _hovered
        ? const Color(0xCC8A2A1F)
        : const Color(0x1AFFFFFF);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gold.withAlpha(170)),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: gold.withAlpha(110),
                        blurRadius: 10,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.isActive)
                  Container(
                    width: 3,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8A22A3),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(14),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 3),
                const SizedBox(width: 14),
                Icon(widget.item.icon, color: const Color(0xFFF4E8CC), size: 22),
                const SizedBox(width: 10),
                Text(
                  widget.item.label,
                  style: const TextStyle(
                    color: Color(0xFFF4E8CC),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
