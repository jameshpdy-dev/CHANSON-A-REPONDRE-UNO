import 'card_image_model.dart';

/// Represents one locally persisted PNG-only deck.
class DeckModel {
  /// Creates an imported deck.
  const DeckModel({
    required this.id,
    required this.name,
    required this.cards,
    required this.createdAt,
    this.source = DeckSource.imported,
    this.coverAsset,
  });

  /// Recreates a deck from local metadata.
  factory DeckModel.fromJson(Map<String, dynamic> json) => DeckModel(
    id: json['id'] as String,
    name: json['name'] as String,
    cards: (json['cards'] as List<dynamic>)
        .map((card) => CardImageModel.fromJson(card as Map<String, dynamic>))
        .toList(growable: false),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  /// The storage folder identifier.
  final String id;

  /// The user-provided deck name.
  final String name;

  /// The PNG card images belonging to this deck.
  final List<CardImageModel> cards;

  /// The original import time.
  final DateTime createdAt;
  final DeckSource source;
  final String? coverAsset;

  bool get isBundled => source == DeckSource.bundled;
  bool get isEditable => !isBundled;
  bool get isDeletable => !isBundled;

  /// Serializes deck metadata for local persistence.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cards': cards.map((card) => card.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}

enum DeckSource { bundled, imported }
