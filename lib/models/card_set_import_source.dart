import 'dart:typed_data';

/// Carries a user-selected file or folder into the CardSet import workflow.
class CardSetImportSource {
  /// Creates an import source from a platform picker or a drop event.
  const CardSetImportSource({
    required this.name,
    this.path,
    this.bytes,
  });

  /// The selected file or folder name.
  final String name;

  /// The native file or folder path when a platform exposes one.
  final String? path;

  /// File bytes supplied by Web and mobile pickers.
  final Uint8List? bytes;
}
