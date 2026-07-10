class GameRecommendationBand {
  final String label;
  final int minMonths;
  final int maxMonths;

  GameRecommendationBand({
    required this.label,
    required this.minMonths,
    required this.maxMonths,
  });

  factory GameRecommendationBand.fromJson(Map<String, dynamic> json) {
    return GameRecommendationBand(
      label: json['label'] ?? '',
      minMonths: json['minMonths'] is int
          ? json['minMonths']
          : int.tryParse('${json['minMonths']}') ?? 0,
      maxMonths: json['maxMonths'] is int
          ? json['maxMonths']
          : int.tryParse('${json['maxMonths']}') ?? 0,
    );
  }
}

class GameRecommendationItem {
  final String gameType;
  final Map<String, dynamic> params;
  final String? reason;

  GameRecommendationItem({
    required this.gameType,
    required this.params,
    this.reason,
  });

  factory GameRecommendationItem.fromJson(Map<String, dynamic> json) {
    return GameRecommendationItem(
      gameType: json['gameType'] ?? '',
      params: (json['params'] is Map<String, dynamic>)
          ? (json['params'] as Map<String, dynamic>)
          : <String, dynamic>{},
      reason: json['reason'],
    );
  }
}

class GameRecommendationResponse {
  final String childId;
  final int ageMonths;
  final GameRecommendationBand? band;
  final List<GameRecommendationItem> games;

  GameRecommendationResponse({
    required this.childId,
    required this.ageMonths,
    required this.band,
    required this.games,
  });

  factory GameRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final bandJson = json['band'];
    final gamesJson = json['games'];

    return GameRecommendationResponse(
      childId: json['childId'] ?? '',
      ageMonths: json['ageMonths'] is int
          ? json['ageMonths']
          : int.tryParse('${json['ageMonths']}') ?? 0,
      band: bandJson is Map<String, dynamic>
          ? GameRecommendationBand.fromJson(bandJson)
          : null,
      games: gamesJson is List
          ? gamesJson
              .whereType<Map<String, dynamic>>()
              .map((e) => GameRecommendationItem.fromJson(e))
              .toList()
          : <GameRecommendationItem>[],
    );
  }
}
