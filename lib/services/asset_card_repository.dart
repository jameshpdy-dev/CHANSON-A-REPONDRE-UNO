import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/app_constants.dart';
import '../models/card_catalog.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../repositories/card_repository.dart';

class AssetCardRepository implements CardRepository {
  const AssetCardRepository([this._bundle]);

  final AssetBundle? _bundle;

  @override
  Future<CardCatalog> load() async {
    final source = await (_bundle ?? rootBundle).loadString(
      AppConstants.cardsAsset,
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The card catalog must be a JSON object.');
    }

    final rawDecks = decoded['decks'];
    final rawCards = decoded['cards'];
    if (rawDecks is! List<dynamic> || rawCards is! List<dynamic>) {
      throw const FormatException('The card catalog requires decks and cards.');
    }

    return CardCatalog(
      decks: rawDecks
          .whereType<Map<String, dynamic>>()
          .map(Deck.fromJson)
          .where((deck) => deck.id.isNotEmpty)
          .toList(growable: false),
      cards: rawCards
          .whereType<Map<String, dynamic>>()
          .map(ChansonCard.fromJson)
          .where((card) => card.id.isNotEmpty && card.deckId.isNotEmpty)
          .toList(growable: false),
    );
  }
}
