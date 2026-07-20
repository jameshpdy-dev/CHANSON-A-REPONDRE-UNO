import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/card_chat_message.dart';

class CardChatMessageBubble extends StatelessWidget {
  const CardChatMessageBubble({required this.message, super.key});
  final CardChatMessage message;
  @override
  Widget build(BuildContext context) {
    final user = message.role == 'user';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Card(
          color: user ? Theme.of(context).colorScheme.primaryContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: user
                ? Text(message.content)
                : MarkdownBody(data: message.content, selectable: true),
          ),
        ),
      ),
    );
  }
}
