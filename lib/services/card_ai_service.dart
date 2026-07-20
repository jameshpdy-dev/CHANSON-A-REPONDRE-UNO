import '../models/card_chat_message.dart';
import '../models/card_image_model.dart';
import '../models/card_transcription_result.dart';

enum TranscriptionMode { exact, clean }

enum DiscussionMode {
  general,
  literary,
  psychological,
  historical,
  creative,
  translation,
  summary,
  factCheck,
}

typedef CardDiscussionMode = DiscussionMode;

abstract interface class CardAiService {
  bool get isConfigured;
  String get model;

  Future<CardTranscriptionResult> transcribeCardImage(
    CardImageModel card, {
    TranscriptionMode mode = TranscriptionMode.exact,
  });

  Future<String> discussCard({
    required CardImageModel card,
    required String prompt,
    required DiscussionMode mode,
    required List<CardChatMessage> history,
    String? targetLanguage,
    String? summaryLength,
  });
}

extension CardAiStreaming on CardAiService {
  Stream<String> discussCardStream({
    required CardImageModel card,
    required String prompt,
    required DiscussionMode mode,
    required List<CardChatMessage> history,
    String? targetLanguage,
    String? summaryLength,
  }) async* {
    yield await discussCard(
      card: card,
      prompt: prompt,
      mode: mode,
      history: history,
      targetLanguage: targetLanguage,
      summaryLength: summaryLength,
    );
  }
}

class CardAiException implements Exception {
  const CardAiException(this.message, {this.canRetry = true});
  final String message;
  final bool canRetry;
  @override
  String toString() => message;
}
