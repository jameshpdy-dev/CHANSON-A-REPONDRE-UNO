enum ChatRole { user, assistant, system }

class CardChatMessage {
  const CardChatMessage({
    required this.id,
    required this.cardId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.completed = true,
    this.error,
  });

  final String id;
  final String cardId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool completed;
  final String? error;

  ChatRole get chatRole => ChatRole.values.firstWhere(
    (value) => value.name == role,
    orElse: () => ChatRole.user,
  );

  factory CardChatMessage.fromJson(Map<String, dynamic> json) =>
      CardChatMessage(
        id: json['id'] as String? ?? '',
        cardId: json['cardId'] as String? ?? '',
        role: json['role'] as String? ?? 'user',
        content: json['content'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        completed: json['completed'] as bool? ?? true,
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'role': role,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'completed': completed,
    'error': error,
  };
}
