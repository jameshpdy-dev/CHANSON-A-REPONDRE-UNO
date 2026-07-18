import 'package:flutter/material.dart';

/// Renders a browser-persisted PNG data URI.
class LocalCardImage extends StatelessWidget {
  /// Creates a browser card image.
  const LocalCardImage({required this.path, required this.fit, super.key});

  /// The PNG data URI.
  final String path;

  /// The image fit mode.
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Image.network(path, fit: fit);
}
