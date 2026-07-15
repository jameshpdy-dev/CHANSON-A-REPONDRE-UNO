import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_constants.dart';
import 'core/app_router.dart';
import 'providers/catalog_provider.dart';
import 'services/asset_card_repository.dart';
import 'theme/app_theme.dart';

class ChansonUnoApp extends StatelessWidget {
  const ChansonUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatalogProvider(const AssetCardRepository())..load(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
