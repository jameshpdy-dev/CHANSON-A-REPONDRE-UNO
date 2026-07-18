/// Represents one artistic prompt card loaded from the application's JSON data.
class CardItem {
  /// Creates an immutable card record.
  const CardItem({
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
    this.emotion,
    this.theme,
    this.country,
    this.source = CardSource.bundled,
    this.originalFilename,
    this.thumbnail,
    this.mimeType,
    this.sizeBytes,
    this.importedAt,
    this.checksum,
    this.transcription,
  });

  /// Creates a card from a JSON object.
  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'].toString(),
      deckId: json['deckId'].toString(),
      title: json['title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      image: json['image'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
      video: json['video'] as String? ?? '',
      category: json['category'] as String? ?? '',
      colour: json['colour'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? const []),
      favorite: json['favorite'] as bool? ?? false,
      emotion: json['emotion'] as String?,
      theme: json['theme'] as String?,
      country: json['country'] as String?,
      source: CardSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => CardSource.bundled,
      ),
      originalFilename: json['originalFilename'] as String?,
      thumbnail: json['thumbnail'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: json['sizeBytes'] as int?,
      importedAt: json['importedAt'] == null
          ? null
          : DateTime.tryParse(json['importedAt'] as String),
      checksum: json['checksum'] as String?,
      transcription: json['transcription'] as String?,
    );
  }

  /// The stable identifier of the card.
  final String id;

  /// The identifier of the deck that contains the card.
  final String deckId;

  /// The card title.
  final String title;

  /// The question presented to a participant.
  final String question;

  /// The card's answer or response prompt.
  final String answer;

  /// The optional artwork asset path.
  final String image;

  /// The optional audio asset or file path.
  final String audio;

  /// The optional video asset or file path.
  final String video;

  /// The card category.
  final String category;

  /// The card's matching colour.
  final String colour;

  /// The optional literary quotation.
  final String quote;

  /// The quotation or card author.
  final String author;

  /// The relevant publication or creation year.
  final int year;

  /// Searchable labels assigned to the card.
  final List<String> tags;

  /// Whether the card is marked as a favourite.
  final bool favorite;

  /// An optional emotion used by search filters.
  final String? emotion;

  /// An optional theme used by search filters.
  final String? theme;

  /// An optional country used by search filters.
  final String? country;
  final CardSource source;
  final String? originalFilename;
  final String? thumbnail;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? importedAt;
  final String? checksum;
  final String? transcription;

  bool get isImported => source == CardSource.imported;

  /// Serializes the card for export and local editing.
  Map<String, dynamic> toJson() {
    return {
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
      'source': source.name,
      'originalFilename': originalFilename,
      'thumbnail': thumbnail,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'importedAt': importedAt?.toIso8601String(),
      'checksum': checksum,
      'transcription': transcription,
    };
  }

  /// Returns a copy with selected values replaced.
  CardItem copyWith({bool? favorite}) {
    return CardItem(
      id: id,
      deckId: deckId,
      title: title,
      question: question,
      answer: answer,
      image: image,
      audio: audio,
      video: video,
      category: category,
      colour: colour,
      quote: quote,
      author: author,
      year: year,
      tags: tags,
      favorite: favorite ?? this.favorite,
      emotion: emotion,
      theme: theme,
      country: country,
      source: source,
      originalFilename: originalFilename,
      thumbnail: thumbnail,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      importedAt: importedAt,
      checksum: checksum,
      transcription: transcription,
    );
  }
}

enum CardSource { bundled, imported }
