import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_router.dart';
import '../widgets/home_navigation_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.message, super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Page not found'),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: HomeNavigationButton(),
        ),
      ],
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 54),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: const Text('Home'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
