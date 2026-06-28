/// Artikulasi Session Model
/// Represents a single articulation practice session
class ArtikulasiSessionModel {
  final String id;
  final String childId;
  final String targetWord;
  final String targetSound;
  final int roundNumber;
  final bool parentRating; // true = thumbs up, false = thumbs down
  final String? parentNotes;
  final String? audioUrl;
  final int sessionScore;
  final DateTime playedAt;
  final DateTime createdAt;

  ArtikulasiSessionModel({
    required this.id,
    required this.childId,
    required this.targetWord,
    required this.targetSound,
    required this.roundNumber,
    required this.parentRating,
    this.parentNotes,
    this.audioUrl,
    required this.sessionScore,
    required this.playedAt,
    required this.createdAt,
  });

  factory ArtikulasiSessionModel.fromJson(Map<String, dynamic> json) {
    return ArtikulasiSessionModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      targetWord: json['targetWord'] ?? json['target_word'] ?? '',
      targetSound: json['targetSound'] ?? json['target_sound'] ?? '',
      roundNumber: json['roundNumber'] ?? json['round_number'] ?? 1,
      parentRating: json['parentRating'] ?? json['parent_rating'] ?? false,
      parentNotes: json['parentNotes'] ?? json['parent_notes'],
      audioUrl: json['audioUrl'] ?? json['audio_url'],
      sessionScore: json['sessionScore'] ?? json['session_score'] ?? 0,
      playedAt: json['playedAt'] != null
          ? DateTime.parse(json['playedAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'targetWord': targetWord,
      'targetSound': targetSound,
      'roundNumber': roundNumber,
      'parentRating': parentRating,
      'parentNotes': parentNotes,
      'audioUrl': audioUrl,
      'sessionScore': sessionScore,
      'playedAt': playedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Sound Statistics
class SoundStatModel {
  final String sound;
  final int total;
  final int correct;
  final int incorrect;
  final int rate; // percentage
  final String status; // mastered, improving, practicing, struggling, not_started

  SoundStatModel({
    required this.sound,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.rate,
    required this.status,
  });

  factory SoundStatModel.fromJson(Map<String, dynamic> json) {
    return SoundStatModel(
      sound: json['sound'] ?? '',
      total: json['total'] ?? 0,
      correct: json['correct'] ?? 0,
      incorrect: json['incorrect'] ?? 0,
      rate: json['rate'] ?? 0,
      status: json['status'] ?? 'not_started',
    );
  }
}

/// Artikulasi Summary (for therapist)
class ArtikulasiSummaryModel {
  final Map<String, SoundStatModel> soundStats;
  final List<String> masteredSounds;
  final List<String> strugglingSounds;
  final int totalSessions;
  final List<ArtikulasiSessionModel> latestSessions;
  final String? recommendation;

  ArtikulasiSummaryModel({
    required this.soundStats,
    required this.masteredSounds,
    required this.strugglingSounds,
    required this.totalSessions,
    required this.latestSessions,
    this.recommendation,
  });

  factory ArtikulasiSummaryModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['soundStats'] as Map<String, dynamic>? ?? {};
    final soundStats = statsJson.map(
      (key, value) => MapEntry(key, SoundStatModel.fromJson(value as Map<String, dynamic>)),
    );

    final mastered = (json['summary']?['masteredSounds'] as List?)?.cast<String>() ?? [];
    final struggling = (json['summary']?['strugglingSounds'] as List?)?.cast<String>() ?? [];

    final sessionsJson = json['latestSessions'] as List? ?? [];
    final latestSessions = sessionsJson
        .map((e) => ArtikulasiSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ArtikulasiSummaryModel(
      soundStats: soundStats,
      masteredSounds: mastered,
      strugglingSounds: struggling,
      totalSessions: json['summary']?['totalPractice'] ?? 0,
      latestSessions: latestSessions,
      recommendation: json['evaluation']?['recommendation'],
    );
  }
}