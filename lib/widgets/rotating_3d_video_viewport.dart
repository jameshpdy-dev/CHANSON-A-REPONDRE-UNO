import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import 'glowing_video_play_button.dart';
import 'video_back_face.dart';
import 'video_viewport_controls.dart';

const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class Rotating3dVideoViewport extends StatefulWidget {
  const Rotating3dVideoViewport({
    required this.assetPath,
    this.onPlayingChanged,
    super.key,
  });

  final String assetPath;
  final ValueChanged<bool>? onPlayingChanged;

  @override
  State<Rotating3dVideoViewport> createState() =>
      _Rotating3dVideoViewportState();
}

class _Rotating3dVideoViewportState extends State<Rotating3dVideoViewport>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _rotation;
  VideoPlayerController? _video;
  Object? _error;
  bool _initializing = true;
  bool _rotationRunning = true;
  bool _reversed = false;
  bool _dragging = false;
  double _manualAngle = 0;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _initializeVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (reducedMotion || _isFlutterTest) {
      _rotation.stop();
    } else if (_video?.value.isInitialized == true &&
        _rotationRunning &&
        !_rotation.isAnimating &&
        !_dragging) {
      _rotation.repeat();
    }
  }

  Future<void> _initializeVideo() async {
    final generation = ++_generation;
    final previous = _video;
    _video = null;
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
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      _video = controller;
      setState(() => _initializing = false);
      if (_rotationRunning &&
          !_isFlutterTest &&
          !MediaQuery.disableAnimationsOf(context)) {
        _rotation.repeat();
      }
    } catch (error, stackTrace) {
      await controller.dispose();
      if (!mounted || generation != _generation) return;
      if (kDebugMode) {
        debugPrint(
          'Failed to initialize rotating Home video: $error\n$stackTrace',
        );
      }
      setState(() {
        _initializing = false;
        _error = error;
      });
    }
  }

  Future<void> _toggleVideo() async {
    final controller = _video;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    widget.onPlayingChanged?.call(controller.value.isPlaying);
    if (mounted) setState(() {});
  }

  void _toggleRotation() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    setState(() => _rotationRunning = !_rotationRunning);
    _rotationRunning && _video?.value.isInitialized == true
        ? _rotation.repeat()
        : _rotation.stop();
  }

  void _reverse() => setState(() => _reversed = !_reversed);

  void _reset() {
    _rotation.stop();
    setState(() => _manualAngle = 0);
    _rotation.value = 0;
    if (_rotationRunning &&
        _video?.value.isInitialized == true &&
        !MediaQuery.disableAnimationsOf(context)) {
      _rotation.repeat();
    }
  }

  void _dragStart(DragStartDetails details) {
    _dragging = true;
    _rotation.stop();
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() => _manualAngle += details.delta.dx * .012);
  }

  void _dragEnd(DragEndDetails details) {
    _dragging = false;
    if (_rotationRunning &&
        _video?.value.isInitialized == true &&
        !MediaQuery.disableAnimationsOf(context)) {
      _rotation.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _video?.pause();
      widget.onPlayingChanged?.call(false);
      _rotation.stop();
      if (mounted) setState(() {});
    } else if (_rotationRunning &&
        _video?.value.isInitialized == true &&
        !MediaQuery.disableAnimationsOf(context)) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _rotation.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final mobile = constraints.maxWidth < 600;
      final width = math.min(
        constraints.maxWidth * (mobile ? .92 : .82),
        1100.0,
      );
      final height = math.min(constraints.maxHeight * .78, 680.0);
      return Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotation,
                builder: (context, child) {
                  final direction = _reversed ? -1.0 : 1.0;
                  final angle =
                      _manualAngle + direction * _rotation.value * math.pi * 2;
                  final frontVisible = math.cos(angle) >= 0;
                  final tilt = math.sin(_rotation.value * math.pi * 2) * .04;
                  final perspective = mobile ? .0008 : .0012;
                  return Semantics(
                    label: 'Rotating home video',
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, perspective)
                        ..rotateY(angle)
                        ..rotateX(tilt),
                      child: IndexedStack(
                        index: frontVisible ? 0 : 1,
                        children: [_buildFront(width), const VideoBackFace()],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                child: VideoViewportControls(
                  videoPlaying: _video?.value.isPlaying ?? false,
                  rotationRunning:
                      _rotationRunning &&
                      !_isFlutterTest &&
                      !MediaQuery.disableAnimationsOf(context),
                  onToggleVideo: _toggleVideo,
                  onToggleRotation: _toggleRotation,
                  onReverse: _reverse,
                  onReset: _reset,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildFront(double availableWidth) {
    final controller = _video;
    final ratio =
        controller == null ||
            !controller.value.isInitialized ||
            !controller.value.aspectRatio.isFinite ||
            controller.value.aspectRatio <= 0
        ? 16 / 9
        : controller.value.aspectRatio;
    return GestureDetector(
      onTap: _toggleVideo,
      onLongPress: () => _rotation.stop(),
      onLongPressUp: () {
        if (_rotationRunning &&
            _video?.value.isInitialized == true &&
            !MediaQuery.disableAnimationsOf(context)) {
          _rotation.repeat();
        }
      },
      onHorizontalDragStart: _dragStart,
      onHorizontalDragUpdate: _dragUpdate,
      onHorizontalDragEnd: _dragEnd,
      child: AspectRatio(
        aspectRatio: ratio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: AppTheme.gold, width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                spreadRadius: 4,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildVideoContent(controller, availableWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(VideoPlayerController? controller, double width) {
    if (_initializing) {
      return const Center(
        child: TickerMode(enabled: false, child: CircularProgressIndicator()),
      );
    }
    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Material(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 8),
            const Text(
              'Video unavailable',
              style: TextStyle(color: Colors.white70),
            ),
            OutlinedButton.icon(
              onPressed: _initializeVideo,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final size = controller.value.size;
    return Stack(
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
              onPressed: _toggleVideo,
              size: width < 600 ? 68 : 96,
            ),
          ),
      ],
    );
  }
}
