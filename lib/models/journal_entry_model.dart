class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.modifiedAt,
    this.linkedCardIds = const [],
    this.photoPath,
    this.voicePath,
    this.isFavourite = false,
  });
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String> linkedCardIds;
  String? get cardId => linkedCardIds.firstOrNull;
  final String? photoPath;
  final String? voicePath;
  final bool isFavourite;

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) =>
      JournalEntryModel(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        modifiedAt:
            DateTime.tryParse(json['modifiedAt'] as String? ?? '') ??
            DateTime.now(),
        linkedCardIds: json['linkedCardIds'] is List
            ? (json['linkedCardIds'] as List)
                  .whereType<String>()
                  .where((id) => id.isNotEmpty)
                  .toList(growable: false)
            : json['linkedCardId'] is String
            ? [json['linkedCardId'] as String]
            : json['cardId'] is String
            ? [json['cardId'] as String]
            : const [],
        photoPath: json['photoPath'] as String?,
        voicePath: json['voicePath'] as String?,
        isFavourite: json['isFavourite'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'linkedCardIds': linkedCardIds,
    'photoPath': photoPath,
    'voicePath': voicePath,
    'isFavourite': isFavourite,
  };
  JournalEntryModel copyWith({
    String? text,
    List<String>? linkedCardIds,
    String? photoPath,
    String? voicePath,
    bool? isFavourite,
  }) => JournalEntryModel(
    id: id,
    text: text ?? this.text,
    createdAt: createdAt,
    modifiedAt: DateTime.now(),
    linkedCardIds: linkedCardIds ?? this.linkedCardIds,
    photoPath: photoPath ?? this.photoPath,
    voicePath: voicePath ?? this.voicePath,
    isFavourite: isFavourite ?? this.isFavourite,
  );
}
