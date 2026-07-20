import 'package:flutter/material.dart';

class FullscreenCardToolbar extends StatelessWidget {
  const FullscreenCardToolbar({
    required this.title,
    required this.onClose,
    required this.onFavourite,
    required this.onTranscribe,
    required this.onDiscuss,
    required this.favourite,
    super.key,
  });
  final String title;
  final bool favourite;
  final VoidCallback onClose;
  final VoidCallback onFavourite;
  final VoidCallback onTranscribe;
  final VoidCallback? onDiscuss;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black87,
    child: SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close card viewer',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            tooltip: favourite ? 'Remove favourite' : 'Add favourite',
            onPressed: onFavourite,
            icon: Icon(favourite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Transcribe card',
            onPressed: onTranscribe,
            icon: const Icon(Icons.document_scanner_outlined),
          ),
          IconButton(
            tooltip: 'Discuss with AI',
            onPressed: onDiscuss,
            icon: const Icon(Icons.forum_outlined),
          ),
        ],
      ),
    ),
  );
}
