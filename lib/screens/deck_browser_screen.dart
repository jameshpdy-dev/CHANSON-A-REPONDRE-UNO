import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_router.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/catalog_state_view.dart';
import '../widgets/home_navigation_button.dart';

class DeckBrowserScreen extends StatelessWidget {
  const DeckBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Deck'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: HomeNavigationButton(),
          ),
        ],
      ),
      body: CatalogStateView(
        builder: (context) {
          final catalog = context.watch<CatalogProvider>();
          if (catalog.decks.isEmpty) {
            return const Center(child: Text('No decks available.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 720
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: columns == 1 ? 2.6 : 1.35,
                ),
                itemCount: catalog.decks.length,
                itemBuilder: (context, index) {
                  final deck = catalog.decks[index];
                  final cardCount = catalog.cardsForDeck(deck.id).length;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.decks),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.style_rounded,
                              color: AppTheme.brightGold,
                              size: 30,
                            ),
                            const Spacer(),
                            Text(
                              deck.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$cardCount ${cardCount == 1 ? 'card' : 'cards'}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
