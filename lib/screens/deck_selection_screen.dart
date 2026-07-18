import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/deck_model.dart';
import '../providers/deck_provider.dart';
import '../widgets/deck_tile.dart';

/// Lets users import, open, and delete locally stored PNG decks.
class DeckSelectionScreen extends StatelessWidget {
  /// Creates the imported deck selection screen.
  const DeckSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeckProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Selection'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton.icon(
              onPressed: state.busy ? null : () => _selectPngDeck(context),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('IMPORT PNG DECK'),
            ),
          ),
          if (state.error case final String error)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: state.busy && state.decks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.decks.isEmpty
                ? const Center(child: Text('No imported PNG decks.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.decks.length,
                    itemBuilder: (context, index) {
                      final deck = state.decks[index];
                      return DeckTile(
                        deck: deck,
                        onOpen: () => context.go('/decks/${deck.id}'),
                        onDelete: () => _confirmDelete(context, deck),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPngDeck(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (result == null || result.files.isEmpty || !context.mounted) {
      return;
    }
    final name = await _askDeckName(context);
    if (name == null || !context.mounted) return;
    await context.read<DeckProvider>().importDeck(name, result.files);
  }

  Future<String?> _askDeckName(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deck name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create deck'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name;
  }

  Future<void> _confirmDelete(BuildContext context, DeckModel deck) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${deck.name}?'),
        content: const Text(
          'The copied PNG cards will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (approved == true && context.mounted) {
      await context.read<DeckProvider>().deleteDeck(deck);
    }
  }
}
