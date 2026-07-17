import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VideoBackFace extends StatelessWidget {
  const VideoBackFace({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF090806),
        border: Border.all(color: AppTheme.gold, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(
          Icons.theater_comedy_rounded,
          color: AppTheme.gold,
          size: 72,
        ),
      ),
    ),
  );
}
