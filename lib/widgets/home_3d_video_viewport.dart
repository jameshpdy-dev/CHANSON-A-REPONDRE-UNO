import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_experience_provider.dart';
import 'startup_video_viewport.dart';

class Home3dVideoViewport extends StatelessWidget {
  const Home3dVideoViewport({super.key});

  @override
  Widget build(BuildContext context) {
    final experience = context.watch<HomeExperienceProvider>();
    final progress = experience.curtainProgress;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final scale = reducedMotion ? 1.0 : 1 - progress * .22;
    return IgnorePointer(
      ignoring: opacity <= .02,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: const StartupVideoViewport(),
        ),
      ),
    );
  }
}
