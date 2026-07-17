import 'package:flutter/material.dart';

class ZoomableCardView extends StatefulWidget {
  const ZoomableCardView({
    required this.child,
    required this.onZoomChanged,
    super.key,
  });
  final Widget child;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ZoomableCardView> createState() => _ZoomableCardViewState();
}

class _ZoomableCardViewState extends State<ZoomableCardView> {
  final controller = TransformationController();
  bool zoomed = false;

  void updateZoom() {
    final next = controller.value.getMaxScaleOnAxis() > 1.01;
    if (next == zoomed) return;
    zoomed = next;
    widget.onZoomChanged(next);
    setState(() {});
  }

  void reset() {
    controller.value = Matrix4.identity();
    updateZoom();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTap: reset,
    child: InteractiveViewer(
      transformationController: controller,
      minScale: 1,
      maxScale: 5,
      boundaryMargin: const EdgeInsets.all(80),
      panEnabled: zoomed,
      onInteractionUpdate: (_) => updateZoom(),
      onInteractionEnd: (_) => updateZoom(),
      child: widget.child,
    ),
  );
}
