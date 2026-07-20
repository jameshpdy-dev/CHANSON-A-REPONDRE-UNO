import 'card_chat_message.dart';

class CardChatSession {
  const CardChatSession({
    required this.id,
    required this.cardId,
    required this.deckId,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String cardId;
  final String deckId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CardChatMessage> messages;
}
