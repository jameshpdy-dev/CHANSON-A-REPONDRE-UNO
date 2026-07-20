import '../models/card_image_model.dart';
import '../services/local_storage_service.dart';

class CardTranscriptionStorageService {
  CardTranscriptionStorageService(this._storage);
  final LocalStorageService _storage;
  String _key(String cardId) => 'card_ai_$cardId';
  Future<void> save(CardImageModel card) =>
      _storage.write(_key(card.id), card.toJson());
  Future<void> delete(String cardId) => _storage.remove(_key(cardId));
}
