import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_router.dart';
import 'providers/cards_provider.dart';
import 'providers/deck_provider.dart';
import 'services/asset_card_repository.dart';
import 'services/deck_import_service.dart';
import 'services/deck_storage_service.dart';
import 'theme/app_theme.dart';

/// Configures the application-level Material theme and metadata.
class ChansonARepondreUnoApp extends StatelessWidget {
  /// Creates the root application widget.
  const ChansonARepondreUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = DeckStorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              CardsProvider(const AssetCardRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              DeckProvider(storage, DeckImportService(storage))..load(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Chanson a Repondre UNO!',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.vintageTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
