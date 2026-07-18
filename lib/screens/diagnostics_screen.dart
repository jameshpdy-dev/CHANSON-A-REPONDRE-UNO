import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/build_info.dart';
import '../providers/cards_provider.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardsState = context.watch<CardsProvider>();
    final status = cardsState.isLoading
        ? 'Loading'
        : cardsState.errorMessage == null
        ? 'Ready'
        : 'Error';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Home',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _DiagnosticRow(label: 'Build', value: buildSha),
          _DiagnosticRow(label: 'App variant', value: appVariant),
          const _DiagnosticRow(
            label: 'Bundled decks',
            value: '$bundledDeckCount',
          ),
          _DiagnosticRow(
            label: 'Bundled cards',
            value: '${cardsState.bundledCount}',
          ),
          _DiagnosticRow(
            label: 'Expected bundled cards',
            value: '$bundledCardCount',
          ),
          _DiagnosticRow(
            label: 'Imported cards',
            value: '${cardsState.importedCount}',
          ),
          _DiagnosticRow(
            label: 'Total visible cards',
            value: '${cardsState.visibleCount}',
          ),
          _DiagnosticRow(label: 'Library status', value: status),
          if (cardsState.errorMessage case final String message)
            _DiagnosticRow(label: 'Load error', value: message),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }
}
