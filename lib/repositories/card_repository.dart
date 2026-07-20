import '../models/card_catalog.dart';

abstract interface class CardRepository {
  Future<CardCatalog> load();
}
