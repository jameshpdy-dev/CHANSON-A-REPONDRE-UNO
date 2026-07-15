import 'package:flutter/material.dart';

import '../core/app_constants.dart';

class BackgroundShell extends StatelessWidget {
  const BackgroundShell({
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppConstants.backgroundAsset,
          fit: BoxFit.cover,
          alignment: alignment,
          semanticLabel: 'Chanson à Répondre UNO card table',
        ),
        const ColoredBox(color: Color(0x4D000000)),
        child,
      ],
    );
  }
}
