import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/card_chat_message.dart';
import '../models/card_image_model.dart';
import '../models/card_transcription_result.dart';
import '../models/ai_health_status.dart';
import '../services/card_ai_service.dart';
import '../services/card_chat_storage_service.dart';
import '../services/card_ai_api_service.dart';
import '../services/card_transcription_storage_service.dart';
import '../services/local_storage_service.dart';
import 'deck_provider.dart';

class CardAiProvider extends ChangeNotifier {
  CardAiProvider({
    required this._service,
    required this._decks,
    required LocalStorageService localStorage,
  }) : _storage = CardTranscriptionStorageService(localStorage),
       _chatStorage = CardChatStorageService(localStorage),
       _localStorage = localStorage;

  final CardAiService _service;
  final DeckProvider _decks;
  final CardTranscriptionStorageService _storage;
  final CardChatStorageService _chatStorage;
  final LocalStorageService _localStorage;
  static const _uuid = Uuid();
  static const _consentKey = 'ai_consent_dismissed';

  bool isLoading = false;
  bool connectionChecking = false;
  bool connectionAvailable = false;
  bool aiEnabled = true;
  AiHealthStatus? healthStatus;
  String? error;
  String? lastPrompt;
  DiscussionMode discussionMode = DiscussionMode.general;
  int _requestGeneration = 0;

  bool get isConfigured => aiEnabled && _service.isConfigured;
  String get model => _service.model;

  Future<void> testConnection() async {
    if (connectionChecking || _service is! CardAiApiService) return;
    connectionChecking = true;
    error = null;
    notifyListeners();
    try {
      healthStatus = await (_service).checkConnection();
      connectionAvailable = healthStatus?.status == 'ok';
    } on Object catch (exception) {
      connectionAvailable = false;
      error = '$exception';
    } finally {
      connectionChecking = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void setAiEnabled(bool value) {
    aiEnabled = value;
    if (!value) cancelCurrentRequest();
    notifyListeners();
  }

  Future<bool> hasConsent() async =>
      await _localStorage.read(_consentKey) == 'true';
  Future<void> rememberConsent() => _localStorage.write(_consentKey, true);

  Future<CardImageModel?> transcribe(
    String cardId,
    TranscriptionMode mode,
  ) async {
    if (!isConfigured) {
      error = 'No AI backend configured.';
      notifyListeners();
      return null;
    }
    final card = _decks.cardById(cardId);
    if (card == null) {
      error = 'This card was deleted during processing.';
      notifyListeners();
      return null;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _service.transcribeCardImage(card, mode: mode);
      final current = _decks.cardById(cardId);
      if (current == null) {
        throw const CardAiException(
          'This card was deleted during processing.',
          canRetry: false,
        );
      }
      final updated = current.copyWith(
        transcription: mode == TranscriptionMode.exact
            ? result.exactText
            : null,
        cleanedTranscription: mode == TranscriptionMode.clean
            ? result.cleanedText
            : null,
        transcriptionLanguage: result.detectedLanguage,
        transcribedAt: result.createdAt,
        transcriptionModel: result.model ?? _service.model,
        transcriptionRequestId: result.requestId,
        transcriptionStatus: result.suggestedStatus,
        transcriptionReviewed: false,
      );
      await _decks.updateCard(updated);
      await _storage.save(updated);
      return updated;
    } on Object catch (exception) {
      error = '$exception';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTranscription(
    String cardId, {
    required String text,
    required TranscriptionMode mode,
  }) async {
    final card = _decks.cardById(cardId);
    if (card == null) return;
    final updated = card.copyWith(
      transcription: mode == TranscriptionMode.exact ? text : null,
      cleanedTranscription: mode == TranscriptionMode.clean ? text : null,
      transcriptionReviewed: true,
      transcriptionStatus: TranscriptionReviewStatus.reviewed,
      transcribedAt: card.transcribedAt ?? DateTime.now(),
      transcriptionModel: card.transcriptionModel ?? _service.model,
    );
    await _decks.updateCard(updated);
    await _storage.save(updated);
    notifyListeners();
  }

  Future<String?> send(
    String cardId,
    String prompt, {
    String? targetLanguage,
    String? summaryLength,
  }) async {
    if (!isConfigured) {
      error = 'No AI backend configured.';
      notifyListeners();
      return null;
    }
    final card = _decks.cardById(cardId);
    if (card == null || prompt.trim().isEmpty) return null;
    final generation = ++_requestGeneration;
    isLoading = true;
    error = null;
    lastPrompt = prompt;
    final user = CardChatMessage(
      id: _uuid.v4(),
      cardId: cardId,
      role: 'user',
      content: prompt.trim(),
      createdAt: DateTime.now(),
    );
    final pending = [...card.chatHistory, user];
    await _decks.updateCard(card.copyWith(chatHistory: pending));
    notifyListeners();
    try {
      final buffer = StringBuffer();
      await for (final chunk in _service.discussCardStream(
        card: card,
        prompt: prompt.trim(),
        mode: discussionMode,
        history: card.chatHistory.length > 12
            ? card.chatHistory.sublist(card.chatHistory.length - 12)
            : card.chatHistory,
        targetLanguage: targetLanguage,
        summaryLength: summaryLength,
      )) {
        if (generation != _requestGeneration) break;
        buffer.write(chunk);
      }
      final answer = buffer.toString();
      if (answer.trim().isEmpty) {
        if (generation != _requestGeneration) return null;
        throw const CardAiException('The AI service returned an empty reply.');
      }
      final current = _decks.cardById(cardId);
      if (current == null) {
        throw const CardAiException(
          'This card was deleted during processing.',
          canRetry: false,
        );
      }
      final assistant = CardChatMessage(
        id: _uuid.v4(),
        cardId: cardId,
        role: 'assistant',
        content: answer,
        createdAt: DateTime.now(),
        completed: generation == _requestGeneration,
      );
      final updated = current.copyWith(
        chatHistory: [...current.chatHistory, assistant],
      );
      await _decks.updateCard(updated);
      await _storage.save(updated);
      await _chatStorage.save(cardId, updated.chatHistory);
      return answer;
    } on Object catch (exception) {
      if (generation != _requestGeneration) return null;
      error = '$exception';
      return null;
    } finally {
      if (generation == _requestGeneration) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void setMode(DiscussionMode mode) {
    discussionMode = mode;
    notifyListeners();
  }

  void cancelCurrentRequest() {
    _requestGeneration++;
    isLoading = false;
    error = null;
    notifyListeners();
  }

  Future<void> clearChat(String cardId) async {
    final card = _decks.cardById(cardId);
    if (card == null) return;
    final updated = card.copyWith(chatHistory: const []);
    await _decks.updateCard(updated);
    await _storage.save(updated);
    await _chatStorage.clear(cardId);
    notifyListeners();
  }

  Future<void> deleteAiData(String cardId) async {
    await _decks.deleteAiData(cardId);
    await _storage.delete(cardId);
    await _chatStorage.clear(cardId);
    notifyListeners();
  }
}
