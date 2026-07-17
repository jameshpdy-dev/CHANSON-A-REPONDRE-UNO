enum TranscriptionReviewStatus { unreviewed, reviewed, needsReview }

class CardTranscriptionResult {
  const CardTranscriptionResult({
    required this.exactText,
    required this.detectedLanguage,
    required this.createdAt,
    this.cleanedText,
    this.model,
    this.requestId,
  });

  final String exactText;
  final String? cleanedText;
  final String detectedLanguage;
  final DateTime createdAt;
  final String? model;
  final String? requestId;

  TranscriptionReviewStatus get suggestedStatus {
    final text = cleanedText ?? exactText;
    if (text.trim().isEmpty ||
        text.contains('[uncertain]') ||
        text.contains('[unreadable]')) {
      return TranscriptionReviewStatus.needsReview;
    }
    return TranscriptionReviewStatus.unreviewed;
  }
}
