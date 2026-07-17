import 'card_image_model.dart';

class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    this.hand = const [],
  });

  final String id;
  final String name;
  final List<CardImageModel> hand;

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Player',
    hand: (json['hand'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CardImageModel.fromJson)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hand': hand.map((card) => card.toJson()).toList(),
  };

  PlayerModel copyWith({List<CardImageModel>? hand}) =>
      PlayerModel(id: id, name: name, hand: hand ?? this.hand);
}
