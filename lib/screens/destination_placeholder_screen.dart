import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Provides a navigable interim page until a destination's feature is built.
class DestinationPlaceholderScreen extends StatelessWidget {
  /// Creates an interim destination page.
  const DestinationPlaceholderScreen({
    required this.title,
    required this.icon,
    super.key,
  });

  /// The page title.
  final String title;

  /// The page icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Home',
        ),
      ),
      body: Center(
        child: Icon(icon, size: 56, color: const Color(0xFFD5A53C)),
      ),
    );
  }
}
