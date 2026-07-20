import 'package:flutter/material.dart';

class FullscreenPageIndicator extends StatelessWidget {
  const FullscreenPageIndicator({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Card $current of $total',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text('$current / $total'),
      ),
    ),
  );
}
