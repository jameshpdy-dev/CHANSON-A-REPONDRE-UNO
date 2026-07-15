import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 54,
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xE6292115)
              : const Color(0xC714110C),
          border: Border.all(
            color: _isHovered ? AppTheme.brightGold : AppTheme.gold,
            width: _isHovered ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? const [
                  BoxShadow(
                    color: Color(0x55FFC928),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            splashColor: AppTheme.gold.withValues(alpha: 0.24),
            highlightColor: AppTheme.gold.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                children: [
                  Icon(widget.icon, color: AppTheme.brightGold, size: 22),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
