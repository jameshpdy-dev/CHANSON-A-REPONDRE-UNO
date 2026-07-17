import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_chanson_2/models/card_chat_message.dart';
import 'package:uno_chanson_2/models/card_image_model.dart';
import 'package:uno_chanson_2/models/card_transcription_result.dart';
import 'package:uno_chanson_2/models/deck_model.dart';
import 'package:uno_chanson_2/providers/card_ai_provider.dart';
import 'package:uno_chanson_2/providers/deck_provider.dart';
import 'package:uno_chanson_2/services/card_ai_service.dart';
import 'package:uno_chanson_2/services/deck_import_service.dart';
import 'package:uno_chanson_2/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late DeckProvider decks;
  late _MockCardAiService service;
  late CardAiProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    final cards = [_card('card-1'), _card('card-2')];
    await storage.write('decks', [
      Deck(id: 'deck-1', name: 'First deck', cards: cards).toJson(),
    ]);
    decks = DeckProvider(storage, DeckImportService(storage));
    await decks.load();
    service = _MockCardAiService();
    provider = CardAiProvider(
      service: service,
      decks: decks,
      localStorage: storage,
    );
  });

  test('successful mock transcription is saved locally', () async {
    await provider.transcribe('card-1', TranscriptionMode.exact);
    final card = decks.cardById('card-1')!;
    expect(card.transcription, 'Exact card text');
    expect(card.transcriptionModel, 'mock-vision');
    expect(card.transcribedAt, isNotNull);
  });

  test('reviewed transcription can be edited and saved', () async {
    await provider.transcribe('card-1', TranscriptionMode.exact);
    await provider.saveTranscription(
      'card-1',
      text: 'User corrected text',
      mode: TranscriptionMode.exact,
    );
    final card = decks.cardById('card-1')!;
    expect(card.transcription, 'User corrected text');
    expect(card.transcriptionReviewed, isTrue);
  });

  test('chat history is stored only on its card', () async {
    await provider.send('card-1', 'Discuss this');
    expect(decks.cardById('card-1')!.chatHistory, hasLength(2));
    expect(decks.cardById('card-2')!.chatHistory, isEmpty);
  });

  test('mock discussion response is saved', () async {
    final response = await provider.send('card-1', 'What is the theme?');
    expect(response, 'Mock discussion response');
    expect(
      decks.cardById('card-1')!.chatHistory.last.content,
      'Mock discussion response',
    );
  });

  test('deleting AI data affects only the selected card', () async {
    await provider.transcribe('card-1', TranscriptionMode.exact);
    await provider.send('card-1', 'Discuss this');
    await provider.transcribe('card-2', TranscriptionMode.exact);
    await provider.deleteAiData('card-1');
    expect(decks.cardById('card-1')!.transcription, isNull);
    expect(decks.cardById('card-1')!.chatHistory, isEmpty);
    expect(decks.cardById('card-2')!.transcription, isNotNull);
  });

  test('disabled state reflects missing API configuration', () {
    service.configured = false;
    expect(provider.isConfigured, isFalse);
  });

  test('failed transcription exposes readable error', () async {
    service.failTranscription = true;
    final result = await provider.transcribe('card-1', TranscriptionMode.exact);
    expect(result, isNull);
    expect(provider.error, contains('Mock transcription failed'));
  });

  test('moving a card preserves transcription, review, and chat fields', () {
    final original = _card('card-1').copyWith(
      transcription: 'Saved text',
      transcriptionReviewed: true,
      chatHistory: [
        CardChatMessage(
          id: 'message-1',
          cardId: 'card-1',
          role: 'user',
          content: 'Question',
          createdAt: DateTime(2026),
        ),
      ],
    );
    final moved = original.copyWith(deckId: 'deck-2');
    expect(moved.deckId, 'deck-2');
    expect(moved.transcription, 'Saved text');
    expect(moved.transcriptionReviewed, isTrue);
    expect(moved.chatHistory, hasLength(1));
  });
}

CardImageModel _card(String id) => CardImageModel(
  id: id,
  deckId: 'deck-1',
  title: 'Card $id',
  path: 'data:image/png;base64,iVBORw0KGgo=',
  category: 'Parole',
  colour: 'red',
  importedAt: DateTime(2026),
);

class _MockCardAiService implements CardAiService {
  bool configured = true;
  bool failTranscription = false;

  @override
  bool get isConfigured => configured;
  @override
  String get model => 'mock-vision';

  @override
  Future<CardTranscriptionResult> transcribeCardImage(
    CardImageModel card, {
    TranscriptionMode mode = TranscriptionMode.exact,
  }) async {
    if (failTranscription) {
      throw const CardAiException('Mock transcription failed.');
    }
    return CardTranscriptionResult(
      exactText: mode == TranscriptionMode.exact ? 'Exact card text' : '',
      cleanedText: mode == TranscriptionMode.clean ? 'Clean card text' : null,
      detectedLanguage: 'French',
      createdAt: DateTime(2026, 7, 16),
      model: model,
    );
  }

  @override
  Future<String> discussCard({
    required CardImageModel card,
    required String prompt,
    required DiscussionMode mode,
    required List<CardChatMessage> history,
    String? targetLanguage,
    String? summaryLength,
  }) async => 'Mock discussion response';
}
