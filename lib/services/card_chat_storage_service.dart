import 'dart:convert';

import '../models/card_chat_message.dart';
import 'local_storage_service.dart';

class CardChatStorageService {
  CardChatStorageService(this._storage);
  final LocalStorageService _storage;

  String _key(String cardId) => 'card_chat_$cardId';

  Future<List<CardChatMessage>> load(String cardId) async {
    final value = await _storage.read(_key(cardId));
    if (value == null) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CardChatMessage.fromJson)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(String cardId, List<CardChatMessage> messages) =>
      _storage.write(
        _key(cardId),
        messages.map((message) => message.toJson()).toList(),
      );

  Future<void> append(String cardId, CardChatMessage message) async {
    await save(cardId, [...await load(cardId), message]);
  }

  Future<void> clear(String cardId) => _storage.remove(_key(cardId));
}
