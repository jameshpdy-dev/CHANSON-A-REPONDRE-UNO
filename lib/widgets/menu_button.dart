import 'package:flutter/material.dart';

/// A responsive, vintage-styled action button for the home menu.
class MenuButton extends StatelessWidget {
  /// Creates a menu button with an icon, label, and action.
  const MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// The visual cue associated with the destination.
  final IconData icon;

  /// The text displayed in the button.
  final String label;

  /// Invoked when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFE7AC)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFF604514).withValues(alpha: 0.92);
            }
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF926C22).withValues(alpha: 0.95);
            }
            return const Color(0xFF120E09).withValues(alpha: 0.78);
          }),
          overlayColor: const WidgetStatePropertyAll(Color(0x33FFE1A0)),
          side: WidgetStateProperty.resolveWith((states) {
            return BorderSide(
              color: states.contains(WidgetState.hovered)
                  ? const Color(0xFFFFD66D)
                  : const Color(0xFFD5A53C),
              width: states.contains(WidgetState.hovered) ? 1.5 : 1,
            );
          }),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
