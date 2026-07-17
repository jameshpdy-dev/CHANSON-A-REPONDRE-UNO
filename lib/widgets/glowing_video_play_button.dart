import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlowingVideoPlayButton extends StatelessWidget {
  const GlowingVideoPlayButton({
    required this.onPressed,
    this.size = 96,
    super.key,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Play home video',
    child: Tooltip(
      message: 'Play home video',
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC090806),
            border: Border.all(color: AppTheme.brightGold, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAAFF9E18),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            iconSize: size * .48,
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFFFFF2CF),
            ),
          ),
        ),
      ),
    ),
  );
}
