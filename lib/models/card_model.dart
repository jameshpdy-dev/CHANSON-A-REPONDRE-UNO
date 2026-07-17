class ChansonCard {
  const ChansonCard({
    required this.id,
    required this.deckId,
    required this.title,
    required this.question,
    required this.answer,
    required this.image,
    required this.audio,
    required this.video,
    required this.category,
    required this.colour,
    required this.quote,
    required this.author,
    required this.year,
    required this.tags,
    required this.favorite,
    this.emotion = '',
    this.theme = '',
    this.country = '',
  });

  final String id;
  final String deckId;
  final String title;
  final String question;
  final String answer;
  final String image;
  final String audio;
  final String video;
  final String category;
  final String colour;
  final String quote;
  final String author;
  final int? year;
  final List<String> tags;
  final bool favorite;
  final String emotion;
  final String theme;
  final String country;

  factory ChansonCard.fromJson(Map<String, dynamic> json) {
    return ChansonCard(
      id: json['id'] as String? ?? '',
      deckId: json['deckId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      image: json['image'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
      video: json['video'] as String? ?? '',
      category: json['category'] as String? ?? '',
      colour: json['colour'] as String? ?? 'gold',
      quote: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      favorite: json['favorite'] as bool? ?? false,
      emotion: json['emotion'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deckId': deckId,
    'title': title,
    'question': question,
    'answer': answer,
    'image': image,
    'audio': audio,
    'video': video,
    'category': category,
    'colour': colour,
    'quote': quote,
    'author': author,
    'year': year,
    'tags': tags,
    'favorite': favorite,
    'emotion': emotion,
    'theme': theme,
    'country': country,
  };

  ChansonCard copyWith({
    String? id,
    String? deckId,
    String? title,
    String? question,
    String? answer,
    String? image,
    String? audio,
    String? video,
    String? category,
    String? colour,
    String? quote,
    String? author,
    int? year,
    List<String>? tags,
    bool? favorite,
    String? emotion,
    String? theme,
    String? country,
  }) {
    return ChansonCard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      image: image ?? this.image,
      audio: audio ?? this.audio,
      video: video ?? this.video,
      category: category ?? this.category,
      colour: colour ?? this.colour,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      year: year ?? this.year,
      tags: tags ?? this.tags,
      favorite: favorite ?? this.favorite,
      emotion: emotion ?? this.emotion,
      theme: theme ?? this.theme,
      country: country ?? this.country,
    );
  }
}
