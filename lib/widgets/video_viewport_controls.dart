import 'package:flutter/material.dart';

class VideoViewportControls extends StatelessWidget {
  const VideoViewportControls({
    required this.videoPlaying,
    required this.rotationRunning,
    required this.onToggleVideo,
    required this.onToggleRotation,
    required this.onReverse,
    required this.onReset,
    super.key,
  });

  final bool videoPlaying;
  final bool rotationRunning;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleRotation;
  final VoidCallback onReverse;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xCC090806),
    borderRadius: BorderRadius.circular(8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: videoPlaying ? 'Pause video' : 'Play video',
          onPressed: onToggleVideo,
          icon: Icon(
            videoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
        IconButton(
          tooltip: rotationRunning ? 'Pause 3D rotation' : 'Resume 3D rotation',
          onPressed: onToggleRotation,
          icon: Icon(
            rotationRunning
                ? Icons.pause_circle_outline
                : Icons.threed_rotation_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Reverse rotation',
          onPressed: onReverse,
          icon: const Icon(Icons.swap_horiz_rounded),
        ),
        IconButton(
          tooltip: 'Reset orientation',
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    ),
  );
}
