import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/startup_video_provider.dart';
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
                      child: _content(startup, controller),
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
      onTap: startup.hasStarted ? startup.toggle : null,
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
                onPressed: startup.play,
                icon: const Icon(Icons.play_arrow_rounded, size: 42),
                label: const Text('PLAY'),
              ),
            )
          else if (!controller.value.isPlaying)
            Center(
              child: FilledButton.tonalIcon(
                onPressed: startup.play,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Paused'),
              ),
            ),
        ],
      ),
    );
  }
}
