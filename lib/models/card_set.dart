/// Describes an imported PNG-only card set.
class CardSet {
  /// Creates an imported card set.
  const CardSet({
    required this.id,
    required this.name,
    required this.cards,
    required this.createdAt,
  });

  /// Creates a card set from the persisted index JSON.
  factory CardSet.fromJson(Map<String, dynamic> json) {
    return CardSet(
      id: json['id'] as String,
      name: json['name'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map(
            (item) => ImportedCardImage.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Stable local identifier for the set.
  final String id;

  /// The display name used for the storage folder.
  final String name;

  /// The imported PNG cards.
  final List<ImportedCardImage> cards;

  /// When this set was imported.
  final DateTime createdAt;

  /// Serializes this set for the local index.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cards': cards.map((card) => card.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Describes one PNG image belonging to an imported card set.
class ImportedCardImage {
  /// Creates an imported PNG image record.
  const ImportedCardImage({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  /// Creates a record from generated cards JSON.
  factory ImportedCardImage.fromJson(Map<String, dynamic> json) {
    return ImportedCardImage(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  /// Stable local identifier for the imported image.
  final String id;

  /// The initial card title, derived from its filename.
  final String title;

  /// A local file path or web-safe data URI.
  final String imagePath;

  /// Serializes this image into the generated cards JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imagePath': imagePath,
  };
}
