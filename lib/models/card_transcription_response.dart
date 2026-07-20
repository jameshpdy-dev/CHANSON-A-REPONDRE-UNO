import 'card_transcription_result.dart';

class CardTranscriptionResponse {
  const CardTranscriptionResponse({
    required this.cardId,
    required this.exactText,
    required this.detectedLanguage,
    required this.status,
    required this.model,
    required this.createdAt,
    this.cleanedText,
    this.requestId,
  });
  final String cardId;
  final String exactText;
  final String? cleanedText;
  final String detectedLanguage;
  final TranscriptionReviewStatus status;
  final String model;
  final String? requestId;
  final DateTime createdAt;

  factory CardTranscriptionResponse.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing $key.');
      }
      return value;
    }

    final createdAt = DateTime.tryParse(requiredString('createdAt'));
    if (createdAt == null) throw const FormatException('Invalid createdAt.');
    return CardTranscriptionResponse(
      cardId: requiredString('cardId'),
      exactText: json['exactText'] is String ? json['exactText'] as String : '',
      cleanedText: json['cleanedText'] as String?,
      detectedLanguage: requiredString('detectedLanguage'),
      status: TranscriptionReviewStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => TranscriptionReviewStatus.unreviewed,
      ),
      model: requiredString('model'),
      requestId: json['requestId'] as String?,
      createdAt: createdAt,
    );
  }
}
