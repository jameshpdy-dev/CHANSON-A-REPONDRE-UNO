import 'package:flutter/material.dart';

import '../core/app_constants.dart';

class BackgroundShell extends StatelessWidget {
  const BackgroundShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppConstants.backgroundAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          semanticLabel: 'Chanson à Répondre UNO card table',
        ),
        const ColoredBox(color: Color(0x4D000000)),
        SafeArea(child: child),
      ],
    );
  }
}
