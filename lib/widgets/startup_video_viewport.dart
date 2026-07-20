import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/startup_video_provider.dart';
import '../providers/home_experience_provider.dart';
import '../theme/app_theme.dart';

class StartupVideoViewport extends StatefulWidget {
  const StartupVideoViewport({this.compact = false, super.key});
  final bool compact;

  @override
  State<StartupVideoViewport> createState() => _StartupVideoViewportState();
}

class _StartupVideoViewportState extends State<StartupVideoViewport> {
  double tiltX = 0;
  double tiltY = 0;

  void _resetTilt() => setState(() {
    tiltX = 0;
    tiltY = 0;
  });

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<StartupVideoProvider>();
    final experience = context.read<HomeExperienceProvider>();
    final controller = startup.controller;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(
          constraints.maxWidth * (widget.compact ? 1 : .86),
          widget.compact ? 520.0 : 1050.0,
        );
        final height = math.min(
          constraints.maxHeight * (widget.compact ? 1 : .74),
          widget.compact ? 320.0 : 650.0,
        );
        final ratio =
            controller?.value.isInitialized == true &&
                controller!.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9;

        return Center(
          child: MouseRegion(
            onExit: (_) => _resetTilt(),
            onHover: reducedMotion
                ? null
                : (event) {
                    final x = ((event.localPosition.dx / width) - .5).clamp(
                      -.5,
                      .5,
                    );
                    final y = ((event.localPosition.dy / height) - .5).clamp(
                      -.5,
                      .5,
                    );
                    setState(() {
                      tiltY = x * .12;
                      tiltX = -y * .09;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOut,
              width: width,
              height: height,
              transformAlignment: Alignment.center,
              transform: reducedMotion
                  ? Matrix4.identity()
                  : (Matrix4.identity()
                      ..setEntry(3, 2, .001)
                      ..rotateX(tiltX)
                      ..rotateY(tiltY)),
              child: Center(
                child: AspectRatio(
                  aspectRatio: ratio,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.gold, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 24,
                          spreadRadius: 2,
                          color: Color(0x66000000),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _content(startup, controller, experience),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(
    StartupVideoProvider startup,
    VideoPlayerController? controller,
    HomeExperienceProvider experience,
  ) {
    if (startup.loading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: Text('Loading startup video...')),
      );
    }
    if (controller?.value.isInitialized != true) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(startup.error ?? 'Unable to load the startup video.'),
        ),
      );
    }
    final size = controller!.value.size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: startup.hasStarted
          ? () async {
              await startup.toggle();
              if (controller.value.isPlaying) {
                experience.playVideo();
              } else {
                experience.pauseVideo();
              }
            }
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(controller),
            ),
          ),
          if (!startup.hasStarted)
            Center(
              child: FilledButton.tonalIcon(
                autofocus: true,
                onPressed: () async {
                  await startup.play();
                  experience.playVideo();
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 42),
                label: const Text('PLAY'),
              ),
            )
          else if (!controller.value.isPlaying)
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await startup.play();
                  experience.playVideo();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Paused'),
              ),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: const Color(0xAA000000),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
                    onPressed: () async {
                      await startup.toggle();
                      if (controller.value.isPlaying) {
                        experience.playVideo();
                      } else {
                        experience.pauseVideo();
                      }
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                  IconButton(
                    tooltip: startup.muted ? 'Unmute' : 'Mute',
                    onPressed: startup.toggleMuted,
                    icon: Icon(
                      startup.muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Replay',
                    onPressed: () async {
                      await startup.replay();
                      experience.playVideo();
                    },
                    icon: const Icon(Icons.replay_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
