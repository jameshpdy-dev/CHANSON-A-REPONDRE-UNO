import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable Material menu control with pointer and touch feedback.
class MenuButton extends StatefulWidget {
  const MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isHovered ? AppTheme.brightGold : AppTheme.gold;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xE6292115) : const Color(0xCC14110C),
          border: Border.all(color: borderColor, width: _isHovered ? 2 : 1.25),
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered
              ? const [BoxShadow(color: Color(0x55FFC928), blurRadius: 14)]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            splashColor: AppTheme.gold.withValues(alpha: 0.28),
            highlightColor: AppTheme.gold.withValues(alpha: 0.12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 100;
                final icon = Icon(
                  widget.icon,
                  color: AppTheme.brightGold,
                  size: compact ? 24 : 30,
                );
                final label = Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: compact ? 6 : 12,
                  ),
                  child: compact
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [icon, const SizedBox(width: 8), label],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [icon, const SizedBox(height: 8), label],
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
