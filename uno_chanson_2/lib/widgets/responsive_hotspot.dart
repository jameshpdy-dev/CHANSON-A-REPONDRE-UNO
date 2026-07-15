import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ResponsiveHotspot extends StatefulWidget {
  const ResponsiveHotspot({
    required this.label,
    required this.sourceRect,
    required this.sourceSize,
    required this.viewportSize,
    required this.imageAlignment,
    required this.onTap,
    super.key,
  });

  final String label;
  final Rect sourceRect;
  final Size sourceSize;
  final Size viewportSize;
  final Alignment imageAlignment;
  final VoidCallback onTap;

  @override
  State<ResponsiveHotspot> createState() => _ResponsiveHotspotState();
}

class _ResponsiveHotspotState extends State<ResponsiveHotspot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = math.max(
      widget.viewportSize.width / widget.sourceSize.width,
      widget.viewportSize.height / widget.sourceSize.height,
    );
    final renderedSize = widget.sourceSize * scale;
    final overflow = Size(
      renderedSize.width - widget.viewportSize.width,
      renderedSize.height - widget.viewportSize.height,
    );
    final offset = Offset(
      -overflow.width * (widget.imageAlignment.x + 1) / 2,
      -overflow.height * (widget.imageAlignment.y + 1) / 2,
    );
    final rect = Rect.fromLTWH(
      offset.dx + widget.sourceRect.left * scale,
      offset.dy + widget.sourceRect.top * scale,
      widget.sourceRect.width * scale,
      widget.sourceRect.height * scale,
    );

    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        button: true,
        label: widget.label,
        child: Tooltip(
          message: widget.label,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: Material(
              color: _hovered
                  ? AppTheme.gold.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppTheme.brightGold.withValues(alpha: 0.24),
                focusColor: AppTheme.gold.withValues(alpha: 0.16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
