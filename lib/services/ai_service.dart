import 'dart:convert';

import 'local_storage_service.dart';

class AiMessage {
  const AiMessage(this.role, this.text);
  final String role;
  final String text;
  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}

class AiService {
  AiService(this._storage);
  final LocalStorageService _storage;
  static const _historyKey = 'ai_history';

  // Credentials are supplied at runtime and are never stored in source control.
  String get apiKey => const String.fromEnvironment('CHANSON_AI_API_KEY');
  bool get isConfigured => apiKey.isNotEmpty;

  Future<List<AiMessage>> history() async {
    try {
      final source = await _storage.read(_historyKey);
      final list = jsonDecode(source ?? '[]') as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => AiMessage(
              item['role'] as String? ?? 'user',
              item['text'] as String? ?? '',
            ),
          )
          .toList();
    } on Object {
      return [];
    }
  }

  Future<void> save(List<AiMessage> messages) => _storage.write(
    _historyKey,
    messages.map((message) => message.toJson()).toList(),
  );
  Future<void> clear() => _storage.remove(_historyKey);

  Future<String> reply(String prompt) async {
    if (!isConfigured) throw StateError('No AI API key is configured.');
    // A provider-specific HTTP adapter can replace this local deterministic response.
    return 'Consider this question: what memory, feeling, or image does “$prompt” bring forward?';
  }
}
