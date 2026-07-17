import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CurtainClosedPrompt extends StatelessWidget {
  const CurtainClosedPrompt({required this.onOpen, super.key});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Open curtains',
    child: Center(
      child: FilledButton.icon(
        autofocus: true,
        onPressed: onOpen,
        icon: const Icon(Icons.theater_comedy),
        label: const Text('TAP TO OPEN'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xDD090806),
          foregroundColor: AppTheme.brightGold,
          side: const BorderSide(color: AppTheme.gold),
          minimumSize: const Size(160, 54),
        ),
      ),
    ),
  );
}
