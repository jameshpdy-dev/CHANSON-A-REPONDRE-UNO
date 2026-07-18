import 'dart:io';
import 'package:flutter/material.dart';

/// Renders a PNG copied into native application storage.
class LocalCardImage extends StatelessWidget {
  /// Creates a local card image.
  const LocalCardImage({required this.path, required this.fit, super.key});

  /// The local PNG path.
  final String path;

  /// The image fit mode.
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Image.file(File(path), fit: fit);
}
