class CardChatResponse {
  const CardChatResponse({
    required this.cardId,
    required this.message,
    required this.model,
    required this.createdAt,
    this.requestId,
  });
  final String cardId;
  final String message;
  final String model;
  final String? requestId;
  final DateTime createdAt;

  factory CardChatResponse.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing $key.');
      }
      return value;
    }

    final createdAt = DateTime.tryParse(requiredString('createdAt'));
    if (createdAt == null) throw const FormatException('Invalid createdAt.');
    return CardChatResponse(
      cardId: requiredString('cardId'),
      message: requiredString('message'),
      model: requiredString('model'),
      requestId: json['requestId'] as String?,
      createdAt: createdAt,
    );
  }
}
