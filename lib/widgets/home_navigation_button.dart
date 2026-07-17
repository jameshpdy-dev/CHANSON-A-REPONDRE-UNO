import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_router.dart';
import '../providers/game_provider.dart';
import '../services/navigation_guard_service.dart';
import '../theme/app_theme.dart';

class HomeNavigationButton extends StatefulWidget {
  const HomeNavigationButton({
    this.confirmActiveGame = false,
    this.beforeNavigate,
    this.navigationGuard,
    super.key,
  });

  final bool confirmActiveGame;
  final VoidCallback? beforeNavigate;
  final Future<bool> Function()? navigationGuard;

  @override
  State<HomeNavigationButton> createState() => _HomeNavigationButtonState();
}

class _HomeNavigationButtonState extends State<HomeNavigationButton> {
  bool hovered = false;
  bool focused = false;

  Future<void> navigateHome() async {
    if (widget.navigationGuard != null && !await widget.navigationGuard!()) {
      return;
    }
    if (!mounted) return;
    if (widget.confirmActiveGame) {
      final game = context.read<GameProvider>();
      if (game.state != null) {
        final choice = await NavigationGuardService.confirm(
          context,
          title: 'Return to Home?',
          message: 'Your current game will be saved so you can continue later.',
          stayLabel: 'Cancel',
          discardLabel: 'Return Without Saving',
          saveLabel: 'Save and Return',
        );
        if (choice == GuardChoice.stay || !mounted) return;
        if (choice == GuardChoice.save) await game.saveCurrent();
      }
    }
    widget.beforeNavigate?.call();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Return to Home',
    child: MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: Focus(
        onFocusChange: (value) => setState(() => focused = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xDD33210F) : const Color(0xAA100C08),
            shape: BoxShape.circle,
            border: Border.all(
              color: focused ? AppTheme.brightGold : AppTheme.gold,
              width: focused ? 2 : 1,
            ),
            boxShadow: hovered
                ? const [BoxShadow(color: Color(0x66FFC928), blurRadius: 12)]
                : null,
          ),
          child: IconButton(
            tooltip: 'Return to Home',
            onPressed: navigateHome,
            icon: const Icon(Icons.home_rounded, color: AppTheme.brightGold),
          ),
        ),
      ),
    ),
  );
}
