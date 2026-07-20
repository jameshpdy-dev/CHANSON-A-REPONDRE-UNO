import 'package:flutter/material.dart';

enum AiConsentChoice { continueOnce, remember, cancel }

Future<AiConsentChoice> showAiConsentDialog(BuildContext context) async =>
    await showDialog<AiConsentChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send card to AI?'),
        content: const Text(
          'This card image and its extracted text will be sent to an AI service for processing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, AiConsentChoice.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, AiConsentChoice.remember),
            child: const Text('Do not show again'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, AiConsentChoice.continueOnce),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ??
    AiConsentChoice.cancel;
