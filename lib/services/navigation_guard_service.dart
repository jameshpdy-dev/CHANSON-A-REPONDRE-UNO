import 'package:flutter/material.dart';

enum GuardChoice { stay, discard, save }

abstract final class NavigationGuardService {
  static Future<GuardChoice> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String stayLabel = 'Continue Editing',
    String discardLabel = 'Discard Changes',
    String? saveLabel,
  }) async =>
      await showDialog<GuardChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, GuardChoice.stay),
              child: Text(stayLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, GuardChoice.discard),
              child: Text(discardLabel),
            ),
            if (saveLabel != null)
              FilledButton(
                onPressed: () => Navigator.pop(context, GuardChoice.save),
                child: Text(saveLabel),
              ),
          ],
        ),
      ) ??
      GuardChoice.stay;
}
