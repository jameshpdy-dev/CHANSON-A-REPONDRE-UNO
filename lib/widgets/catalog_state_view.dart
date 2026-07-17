import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/catalog_provider.dart';

class CatalogStateView extends StatelessWidget {
  const CatalogStateView({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return switch (catalog.status) {
      CatalogStatus.idle ||
      CatalogStatus.loading => const Center(child: CircularProgressIndicator()),
      CatalogStatus.error => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                'The card catalog could not be loaded.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: catalog.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      CatalogStatus.ready => builder(context),
    };
  }
}
