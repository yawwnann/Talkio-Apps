/// Diagnosa Model
/// Model untuk hasil diagnosa speech delay
class DiagnosaModel {
  final String id;
  final String anakId;
  final String terapisId;
  final String level; // ringan, sedang, berat
  final String description;
  final List<String> recommendations;
  final int score; // 0-100
  final Map<String, dynamic> assessmentData;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  DiagnosaModel({
    required this.id,
    required this.anakId,
    required this.terapisId,
    required this.level,
    required this.description,
    required this.recommendations,
    required this.score,
    required this.assessmentData,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Get level color
  String get levelColor {
    switch (level.toLowerCase()) {
      case 'ringan':
        return '#4CAF50'; // Green
      case 'sedang':
        return '#FF9800'; // Orange
      case 'berat':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
  
  // Get level description
  String get levelDescription {
    switch (level.toLowerCase()) {
      case 'ringan':
        return 'Speech delay ringan - dapat diatasi dengan terapi rutin';
      case 'sedang':
        return 'Speech delay sedang - memerlukan terapi intensif';
      case 'berat':
        return 'Speech delay berat - memerlukan penanganan khusus';
      default:
        return 'Belum ada diagnosa';
    }
  }
  
  // Convert from JSON
  factory DiagnosaModel.fromJson(Map<String, dynamic> json) {
    return DiagnosaModel(
      id: json['id'] ?? '',
      anakId: json['anak_id'] ?? '',
      terapisId: json['terapis_id'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      score: json['score'] ?? 0,
      assessmentData: json['assessment_data'] ?? {},
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anak_id': anakId,
      'terapis_id': terapisId,
      'level': level,
      'description': description,
      'recommendations': recommendations,
      'score': score,
      'assessment_data': assessmentData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Copy with new values
  DiagnosaModel copyWith({
    String? id,
    String? anakId,
    String? terapisId,
    String? level,
    String? description,
    List<String>? recommendations,
    int? score,
    Map<String, dynamic>? assessmentData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosaModel(
      id: id ?? this.id,
      anakId: anakId ?? this.anakId,
      terapisId: terapisId ?? this.terapisId,
      level: level ?? this.level,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      score: score ?? this.score,
      assessmentData: assessmentData ?? this.assessmentData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'DiagnosaModel(id: $id, level: $level, score: $score)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DiagnosaModel &&
        other.id == id &&
        other.anakId == anakId &&
        other.level == level &&
        other.score == score;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        anakId.hashCode ^
        level.hashCode ^
        score.hashCode;
  }
}