import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onViewAll,
    super.key,
  });
  final String title;
  final VoidCallback onViewAll;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppTheme.gold),
      ),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: AppTheme.gold)),
      TextButton.icon(
        onPressed: onViewAll,
        label: const Text('VOIR TOUT'),
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward),
      ),
    ],
  );
}
