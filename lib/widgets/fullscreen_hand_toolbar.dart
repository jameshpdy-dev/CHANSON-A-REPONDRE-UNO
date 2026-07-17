import 'package:flutter/material.dart';

class FullscreenHandToolbar extends StatelessWidget {
  const FullscreenHandToolbar({
    required this.title,
    required this.onClose,
    super.key,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black87,
    child: SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close card preview',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    ),
  );
}
