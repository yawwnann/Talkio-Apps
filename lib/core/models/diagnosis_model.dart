/// Diagnosis Model
/// Model untuk hasil diagnosis dan prediksi speech delay
/// Matches backend API response format
class DiagnosisModel {
  final String id;
  final String childId;
  final List<String> symptoms;
  final String riskLevel; // LOW, MEDIUM, HIGH
  final double score; // 0.0 - 1.0
  final String? recommendation;
  final String? nextStep;
  final DateTime createdAt;

  DiagnosisModel({
    required this.id,
    required this.childId,
    required this.symptoms,
    required this.riskLevel,
    required this.score,
    this.recommendation,
    this.nextStep,
    required this.createdAt,
  });

  // Get risk level color
  String get riskLevelColor {
    switch (riskLevel) {
      case 'LOW':
        return '4CAF50'; // Green
      case 'MEDIUM':
        return 'FFB74D'; // Orange
      case 'HIGH':
        return 'EF4444'; // Red
      default:
        return '94A3B8'; // Grey
    }
  }

  // Get risk level display text
  String get riskLevelDisplay {
    switch (riskLevel) {
      case 'LOW':
        return 'Rendah';
      case 'MEDIUM':
        return 'Sedang';
      case 'HIGH':
        return 'Tinggi';
      default:
        return riskLevel;
    }
  }

  // Get risk level description
  String get riskLevelDescription {
    switch (riskLevel) {
      case 'LOW':
        return 'Lanjutkan pemantauan perkembangan anak.';
      case 'MEDIUM':
        return 'Disarankan untuk observasi lebih lanjut.';
      case 'HIGH':
        return 'Segera jadwalkan konsultasi dengan terapis bicara profesional.';
      default:
        return '';
    }
  }

  // Convert from JSON - matches backend response format
  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      riskLevel: json['riskLevel'] ?? json['risk_level'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      recommendation: json['recommendation'],
      nextStep: json['next_step'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON - for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'symptoms': symptoms,
      'riskLevel': riskLevel,
      'score': score,
      'recommendation': recommendation,
      'nextStep': nextStep,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiagnosisModel(id: $id, riskLevel: $riskLevel, score: $score)';
  }
}
