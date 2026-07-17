import 'package:flutter/material.dart';

class FullscreenCardPageIndicator extends StatelessWidget {
  const FullscreenCardPageIndicator({
    required this.page,
    required this.total,
    super.key,
  });
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Card $page of $total',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text('$page / $total'),
      ),
    ),
  );
}
