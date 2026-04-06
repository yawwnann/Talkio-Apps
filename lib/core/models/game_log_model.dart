/// Game Log Model
/// Model untuk tracking progress permainan edukatif anak
/// Matches backend API response format
class GameLogModel {
  final String id;
  final String childId;
  final int gameScore;
  final int duration; // in seconds
  final String gameType; // Kata Bergambar, Menirukan Suara, etc.
  final DateTime playedAt;

  GameLogModel({
    required this.id,
    required this.childId,
    required this.gameScore,
    required this.duration,
    required this.gameType,
    required this.playedAt,
  });

  // Get formatted duration
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes > 0) {
      return '$minutes menit $seconds detik';
    }
    return '$seconds detik';
  }

  // Get duration in minutes (rounded)
  int get durationInMinutes => (duration / 60).round();

  // Convert from JSON - matches backend response format
  factory GameLogModel.fromJson(Map<String, dynamic> json) {
    return GameLogModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      gameScore: json['gameScore'] ?? json['game_score'] ?? 0,
      duration: json['duration'] ?? 0,
      gameType: json['gameType'] ?? json['game_type'] ?? '',
      playedAt: json['playedAt'] != null
          ? DateTime.parse(json['playedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON - for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'gameScore': gameScore,
      'duration': duration,
      'gameType': gameType,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GameLogModel(id: $id, gameType: $gameType, score: $gameScore)';
  }
}
