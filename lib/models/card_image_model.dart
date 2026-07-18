/// Represents one PNG card image stored in an imported deck.
class CardImageModel {
  /// Creates an imported PNG card image record.
  const CardImageModel({
    required this.id,
    required this.title,
    required this.path,
  });

  /// Recreates a card image record from local metadata.
  factory CardImageModel.fromJson(Map<String, dynamic> json) => CardImageModel(
    id: json['id'] as String,
    title: json['title'] as String,
    path: json['path'] as String,
  );

  /// The stable local card identifier.
  final String id;

  /// The initial card title, derived from its source filename.
  final String title;

  /// The application-storage path of the copied PNG.
  final String path;

  /// Serializes local card metadata.
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'path': path};
}
