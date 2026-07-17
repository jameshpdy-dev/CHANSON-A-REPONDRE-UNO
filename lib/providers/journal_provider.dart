import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry_model.dart';
import '../services/local_storage_service.dart';

class JournalProvider extends ChangeNotifier {
  JournalProvider(this._storage);
  final LocalStorageService _storage;
  static const _key = 'journal_entries';
  static const _uuid = Uuid();
  List<JournalEntryModel> _entries = [];
  List<JournalEntryModel> get entries => List.unmodifiable(_entries);
  Future<void> load() async {
    try {
      final source = await _storage.read(_key);
      _entries = (jsonDecode(source ?? '[]') as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(JournalEntryModel.fromJson)
          .toList();
    } on Object {
      _entries = [];
    }
    notifyListeners();
  }

  Future<void> saveEntry({
    String? id,
    required String text,
    List<String> linkedCardIds = const [],
    String? photoPath,
    String? voicePath,
  }) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index < 0) {
      final now = DateTime.now();
      _entries.add(
        JournalEntryModel(
          id: _uuid.v4(),
          text: text,
          createdAt: now,
          modifiedAt: now,
          linkedCardIds: linkedCardIds,
          photoPath: photoPath,
          voicePath: voicePath,
        ),
      );
    } else {
      _entries[index] = _entries[index].copyWith(
        text: text,
        linkedCardIds: linkedCardIds,
        photoPath: photoPath,
        voicePath: voicePath,
      );
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _persist();
  }

  Future<void> toggleFavourite(String id) async {
    final i = _entries.indexWhere((entry) => entry.id == id);
    if (i >= 0) {
      _entries[i] = _entries[i].copyWith(isFavourite: !_entries[i].isFavourite);
    }
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.write(
      _key,
      _entries.map((entry) => entry.toJson()).toList(),
    );
    notifyListeners();
  }
}
