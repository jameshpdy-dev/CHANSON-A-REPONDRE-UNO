import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'glowing_video_play_button.dart';

class HomeVideoViewport extends StatefulWidget {
  const HomeVideoViewport({
    required this.assetPath,
    this.maxWidth = 1100,
    this.maxHeight = 650,
    super.key,
  });

  final String assetPath;
  final double maxWidth;
  final double maxHeight;

  @override
  State<HomeVideoViewport> createState() => _HomeVideoViewportState();
}

class _HomeVideoViewportState extends State<HomeVideoViewport>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Object? _error;
  bool _initializing = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final generation = ++_generation;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();
    if (!mounted || generation != _generation) return;
    setState(() {
      _initializing = true;
      _error = null;
    });

    final controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await controller.initialize();
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(1);
      await controller.pause();
      _controller = controller;
      setState(() => _initializing = false);
    } catch (error, stackTrace) {
      await controller.dispose();
      if (!mounted || generation != _generation) return;
      if (kDebugMode) {
        debugPrint('Failed to initialize Home video: $error\n$stackTrace');
      }
      setState(() {
        _initializing = false;
        _error = error;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controller?.pause();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontalPadding = constraints.maxWidth < 600 ? 12.0 : 24.0;
      final availableWidth = (constraints.maxWidth - horizontalPadding * 2)
          .clamp(0.0, widget.maxWidth);
      final availableHeight = (constraints.maxHeight - 40).clamp(
        0.0,
        widget.maxHeight,
      );
      return Center(
        child: SizedBox(
          width: availableWidth,
          height: availableHeight,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black87, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: _buildViewport(constraints.maxWidth),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _buildViewport(double viewportWidth) {
    if (_initializing) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: TickerMode(enabled: false, child: CircularProgressIndicator()),
        ),
      );
    }
    final controller = _controller;
    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Video unavailable',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _initialize,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final rawRatio = controller.value.aspectRatio;
    final ratio = rawRatio.isFinite && rawRatio > 0 ? rawRatio : 16 / 9;
    final size = controller.value.size;
    return AspectRatio(
      aspectRatio: ratio,
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: _togglePlayback,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: size.width > 0 ? size.width : 16,
                  height: size.height > 0 ? size.height : 9,
                  child: VideoPlayer(controller),
                ),
              ),
              if (!controller.value.isPlaying)
                Center(
                  child: GlowingVideoPlayButton(
                    onPressed: _togglePlayback,
                    size: viewportWidth < 600 ? 68 : 96,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
