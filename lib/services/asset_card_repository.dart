import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/card_item.dart';
import '../repositories/card_repository.dart';

/// Loads the initial card collection from the bundled JSON asset.
class AssetCardRepository implements CardRepository {
  /// Creates an asset-backed card repository.
  const AssetCardRepository({this.bundle});

  /// An optional bundle used for controlled loading in tests and integrations.
  final AssetBundle? bundle;

  @override
  Future<List<CardItem>> loadCards() async {
    final source = await (bundle ?? rootBundle).loadString('assets/json/cards.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => CardItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
