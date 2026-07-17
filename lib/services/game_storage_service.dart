import 'dart:convert';

import '../models/game_state_model.dart';
import 'local_storage_service.dart';

class GameStorageService {
  GameStorageService(this._storage);
  final LocalStorageService _storage;
  static const _key = 'saved_game';

  Future<void> save(GameStateModel state) =>
      _storage.write(_key, state.toJson());
  Future<GameStateModel?> load() async {
    try {
      final source = await _storage.read(_key);
      if (source == null) return null;
      return GameStateModel.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
    } on Object {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.remove(_key);
}
