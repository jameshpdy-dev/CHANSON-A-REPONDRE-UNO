import 'card_image_model.dart';
import 'player_model.dart';

enum CardColour { red, yellow, green, blue, black, custom }

enum PlayDirection { clockwise, counterClockwise }

enum DrawRule { drawOneAndPass, drawUntilPlayable }

enum MatchRule { colourOnly, categoryOnly, colourOrCategory }

class GameStateModel {
  const GameStateModel({
    required this.deckId,
    required this.topCard,
    required this.currentColour,
    required this.currentCategory,
    required this.playDirection,
    required this.drawPile,
    required this.discardPile,
    required this.players,
    required this.currentPlayerIndex,
    this.drawRule = DrawRule.drawOneAndPass,
    this.matchRule = MatchRule.colourOrCategory,
    this.allowStacking = false,
    this.timedTurns = false,
    this.collaborativeMode = false,
    this.conversationMode = false,
    this.journalMode = false,
    this.winnerName,
  });

  final String deckId;
  final CardImageModel topCard;
  final CardColour currentColour;
  final String currentCategory;
  final PlayDirection playDirection;
  final List<CardImageModel> drawPile;
  final List<CardImageModel> discardPile;
  final List<PlayerModel> players;
  final int currentPlayerIndex;
  final DrawRule drawRule;
  final MatchRule matchRule;
  final bool allowStacking;
  final bool timedTurns;
  final bool collaborativeMode;
  final bool conversationMode;
  final bool journalMode;
  final String? winnerName;

  Map<String, dynamic> toJson() => {
    'deckId': deckId,
    'topCard': topCard.toJson(),
    'currentColour': currentColour.name,
    'currentCategory': currentCategory,
    'playDirection': playDirection.name,
    'drawPile': drawPile.map((card) => card.toJson()).toList(),
    'discardPile': discardPile.map((card) => card.toJson()).toList(),
    'players': players.map((player) => player.toJson()).toList(),
    'currentPlayerIndex': currentPlayerIndex,
    'drawRule': drawRule.name,
    'matchRule': matchRule.name,
    'allowStacking': allowStacking,
    'timedTurns': timedTurns,
    'collaborativeMode': collaborativeMode,
    'conversationMode': conversationMode,
    'journalMode': journalMode,
    'winnerName': winnerName,
  };

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((value) => value.name == name).firstOrNull ?? fallback;
    return GameStateModel(
      deckId: json['deckId'] as String? ?? '',
      topCard: CardImageModel.fromJson(json['topCard'] as Map<String, dynamic>),
      currentColour: enumValue(
        CardColour.values,
        json['currentColour'] as String?,
        CardColour.red,
      ),
      currentCategory: json['currentCategory'] as String? ?? 'Parole',
      playDirection: enumValue(
        PlayDirection.values,
        json['playDirection'] as String?,
        PlayDirection.clockwise,
      ),
      drawPile: _cards(json['drawPile']),
      discardPile: _cards(json['discardPile']),
      players: (json['players'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PlayerModel.fromJson)
          .toList(),
      currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
      drawRule: enumValue(
        DrawRule.values,
        json['drawRule'] as String?,
        DrawRule.drawOneAndPass,
      ),
      matchRule: enumValue(
        MatchRule.values,
        json['matchRule'] as String?,
        MatchRule.colourOrCategory,
      ),
      allowStacking: json['allowStacking'] as bool? ?? false,
      timedTurns: json['timedTurns'] as bool? ?? false,
      collaborativeMode: json['collaborativeMode'] as bool? ?? false,
      conversationMode: json['conversationMode'] as bool? ?? false,
      journalMode: json['journalMode'] as bool? ?? false,
      winnerName: json['winnerName'] as String?,
    );
  }

  static List<CardImageModel> _cards(dynamic value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CardImageModel.fromJson)
          .toList();

  GameStateModel copyWith({
    CardImageModel? topCard,
    CardColour? currentColour,
    String? currentCategory,
    PlayDirection? playDirection,
    List<CardImageModel>? drawPile,
    List<CardImageModel>? discardPile,
    List<PlayerModel>? players,
    int? currentPlayerIndex,
    DrawRule? drawRule,
    MatchRule? matchRule,
    bool? allowStacking,
    bool? timedTurns,
    bool? collaborativeMode,
    bool? conversationMode,
    bool? journalMode,
    String? winnerName,
  }) => GameStateModel(
    deckId: deckId,
    topCard: topCard ?? this.topCard,
    currentColour: currentColour ?? this.currentColour,
    currentCategory: currentCategory ?? this.currentCategory,
    playDirection: playDirection ?? this.playDirection,
    drawPile: drawPile ?? this.drawPile,
    discardPile: discardPile ?? this.discardPile,
    players: players ?? this.players,
    currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    drawRule: drawRule ?? this.drawRule,
    matchRule: matchRule ?? this.matchRule,
    allowStacking: allowStacking ?? this.allowStacking,
    timedTurns: timedTurns ?? this.timedTurns,
    collaborativeMode: collaborativeMode ?? this.collaborativeMode,
    conversationMode: conversationMode ?? this.conversationMode,
    journalMode: journalMode ?? this.journalMode,
    winnerName: winnerName ?? this.winnerName,
  );
}
