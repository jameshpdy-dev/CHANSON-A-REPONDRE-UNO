import 'package:flutter/material.dart';

class CurtainEdgeHandle extends StatelessWidget {
  const CurtainEdgeHandle({
    required this.alignment,
    required this.onDragUpdate,
    required this.onDragEnd,
    super.key,
  });
  final Alignment alignment;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (event) => onDragUpdate(event.delta.dx),
      onHorizontalDragEnd: (event) => onDragEnd(event.primaryVelocity ?? 0),
      child: const SizedBox(width: 44, height: double.infinity),
    ),
  );
}
