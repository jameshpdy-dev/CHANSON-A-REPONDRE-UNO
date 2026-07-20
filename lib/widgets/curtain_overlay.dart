import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/curtain_provider.dart';
import 'curtain_closed_prompt.dart';
import 'curtain_control_button.dart';

class CurtainOverlay extends StatefulWidget {
  const CurtainOverlay({super.key});
  @override
  State<CurtainOverlay> createState() => _CurtainOverlayState();
}

class _CurtainOverlayState extends State<CurtainOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController controller;
  CurtainProvider? provider;
  bool dragging = false;
  bool syncingController = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    controller.addListener(() {
      if (!dragging && !syncingController) {
        provider?.setProgress(controller.value);
      }
    });
    controller.addStatusListener((status) {
      if (syncingController) return;
      if (status == AnimationStatus.completed) provider?.finishAnimation(true);
      if (status == AnimationStatus.dismissed) provider?.finishAnimation(false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = context.read<CurtainProvider>();
    if (provider != next) {
      provider?.removeListener(syncFromProvider);
      provider = next..addListener(syncFromProvider);
      syncingController = true;
      controller.value = next.progress;
      syncingController = false;
    }
    controller.duration = MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 1150);
  }

  void syncFromProvider() {
    final value = provider;
    if (value == null || dragging) return;
    if (value.state == CurtainState.opening) {
      if (controller.status == AnimationStatus.forward) return;
      controller.animateTo(1, curve: Curves.easeInOutCubic).then((_) {
        if (mounted && provider?.state == CurtainState.opening) {
          provider?.finishAnimation(true);
        }
      });
    } else if (value.state == CurtainState.closing) {
      if (controller.status == AnimationStatus.reverse) return;
      controller.animateBack(0, curve: Curves.easeInOutCubic);
    } else if (!controller.isAnimating &&
        (controller.value - value.progress).abs() > .001) {
      controller.value = value.progress;
    }
  }

  void dragUpdate(double delta, double width, bool left) {
    if (width <= 0) return;
    dragging = true;
    controller.stop();
    final direction = left ? -delta : delta;
    final value = (controller.value + direction / (width / 2)).clamp(0.0, 1.0);
    controller.value = value;
    provider?.setProgress(value);
  }

  void dragEnd(double velocity, bool left) {
    dragging = false;
    provider?.completeDrag(left ? -velocity : velocity);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) controller.stop();
  }

  @override
  void dispose() {
    provider?.removeListener(syncFromProvider);
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curtain = context.watch<CurtainProvider>();
    final closed = curtain.progress <= .01;
    final open = curtain.progress >= .99;
    final blocksContent = curtain.progress < .95;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyC): curtain.toggle,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (!closed) curtain.close();
        },
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (closed) curtain.open();
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (closed) curtain.open();
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }
            final curtainWidth = constraints.maxWidth * .58;
            final travel = curtainWidth;
            final leftOffset = -travel * curtain.progress;
            final rightOffset = travel * curtain.progress;
            return Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: !blocksContent,
                  child: ExcludeSemantics(
                    excluding: open,
                    child: Transform.translate(
                      offset: Offset(leftOffset, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _CurtainPanel(
                          label: 'Left theatre curtain',
                          left: true,
                          width: curtainWidth,
                          onTap: curtain.open,
                          onUpdate: (delta) =>
                              dragUpdate(delta, constraints.maxWidth, true),
                          onEnd: (velocity) => dragEnd(velocity, true),
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: !blocksContent,
                  child: ExcludeSemantics(
                    excluding: open,
                    child: Transform.translate(
                      offset: Offset(rightOffset, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _CurtainPanel(
                          label: 'Right theatre curtain',
                          left: false,
                          width: curtainWidth,
                          onTap: curtain.open,
                          onUpdate: (delta) =>
                              dragUpdate(delta, constraints.maxWidth, false),
                          onEnd: (velocity) => dragEnd(velocity, false),
                        ),
                      ),
                    ),
                  ),
                ),
                if (curtain.progress < .15)
                  Positioned.fill(
                    child: Semantics(
                      label: 'Curtains closed. Activate to open.',
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: curtain.open,
                        onHorizontalDragEnd: (details) {
                          if ((details.primaryVelocity ?? 0).abs() > 100) {
                            curtain.open();
                          }
                        },
                        child: CurtainClosedPrompt(onOpen: curtain.open),
                      ),
                    ),
                  ),
                if (open) ...[
                  _EdgeHandle(
                    alignment: Alignment.centerLeft,
                    onUpdate: (delta) =>
                        dragUpdate(delta, constraints.maxWidth, true),
                    onEnd: (velocity) => dragEnd(velocity, true),
                  ),
                  _EdgeHandle(
                    alignment: Alignment.centerRight,
                    onUpdate: (delta) =>
                        dragUpdate(delta, constraints.maxWidth, false),
                    onEnd: (velocity) => dragEnd(velocity, false),
                  ),
                ],
                Positioned(
                  top: 12,
                  right: 12,
                  child: SafeArea(
                    child: CurtainControlButton(
                      isOpen: !closed,
                      onPressed: curtain.toggle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EdgeHandle extends StatelessWidget {
  const _EdgeHandle({
    required this.alignment,
    required this.onUpdate,
    required this.onEnd,
  });

  final Alignment alignment;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onEnd;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Semantics(
      label: 'Curtain edge handle',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onUpdate(details.delta.dx),
        onHorizontalDragEnd: (details) => onEnd(details.primaryVelocity ?? 0),
        child: const SizedBox(width: 40, height: double.infinity),
      ),
    ),
  );
}

class _CurtainPanel extends StatelessWidget {
  const _CurtainPanel({
    required this.label,
    required this.left,
    required this.width,
    required this.onTap,
    required this.onUpdate,
    required this.onEnd,
  });
  final String label;
  final bool left;
  final double width;
  final VoidCallback onTap;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onEnd;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onHorizontalDragUpdate: (details) => onUpdate(details.delta.dx),
      onHorizontalDragEnd: (details) => onEnd(details.primaryVelocity ?? 0),
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: CustomPaint(painter: _CurtainPainter(left: left)),
      ),
    ),
  );
}

class _CurtainPainter extends CustomPainter {
  const _CurtainPainter({required this.left});
  final bool left;
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFF65150F);
    canvas.drawRect(Offset.zero & size, base);
    for (var index = 0; index < 10; index++) {
      final rect = Rect.fromLTWH(
        index * size.width / 10,
        0,
        size.width / 10 + 2,
        size.height,
      );
      final shade = index.isEven
          ? const Color(0xFF8D251A)
          : const Color(0xFF3D0C09);
      canvas.drawRect(rect, Paint()..color = shade);
    }
    final edge = Paint()
      ..color = const Color(0xFFC18A27)
      ..strokeWidth = 3;
    final x = left ? size.width - 2 : 2.0;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), edge);
  }

  @override
  bool shouldRepaint(covariant _CurtainPainter oldDelegate) =>
      oldDelegate.left != left;
}
