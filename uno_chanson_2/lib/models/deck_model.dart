class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  final String id;
  final String name;
  final String description;
  final String image;

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image': image,
  };
}
