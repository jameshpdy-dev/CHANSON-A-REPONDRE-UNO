import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/app_router.dart';
import 'home_navigation_button.dart';

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    required this.title,
    required this.child,
    this.showHomeButton = true,
    this.showBackButton = true,
    this.confirmActiveGameOnHome = false,
    this.actions = const [],
    this.navigationGuard,
    super.key,
  });
  final String title;
  final Widget child;
  final bool showHomeButton;
  final bool showBackButton;
  final bool confirmActiveGameOnHome;
  final List<Widget> actions;
  final Future<bool> Function()? navigationGuard;

  void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.keyH, alt: true): _HomeIntent(),
      SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): _BackIntent(),
    },
    child: Actions(
      actions: {
        _HomeIntent: CallbackAction<_HomeIntent>(
          onInvoke: (_) {
            context.go(AppRoutes.home);
            return null;
          },
        ),
        _BackIntent: CallbackAction<_BackIntent>(
          onInvoke: (_) {
            back(context);
            return null;
          },
        ),
      },
      child: Scaffold(
        appBar: AppBar(
          leading: showBackButton
              ? IconButton(
                  tooltip: 'Back',
                  onPressed: () => back(context),
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          title: Text(title),
          actions: [
            ...actions,
            if (showHomeButton)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: HomeNavigationButton(
                  confirmActiveGame: confirmActiveGameOnHome,
                  navigationGuard: navigationGuard,
                ),
              ),
          ],
        ),
        body: SafeArea(child: child),
      ),
    ),
  );
}

class _HomeIntent extends Intent {
  const _HomeIntent();
}

class _BackIntent extends Intent {
  const _BackIntent();
}
