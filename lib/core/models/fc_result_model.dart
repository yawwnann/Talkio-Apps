/// Forward Chaining Result Model
/// Model untuk hasil diagnosis dari forward chaining engine

class FCResultModel {
  /// Risk level: LOW, MEDIUM, HIGH
  final String riskLevel;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Derived facts dari forward chaining
  final List<String> derivedFacts;

  /// Rules yang aktif
  final List<String> triggeredRules;

  /// Summary hasil assessment
  final Map<String, dynamic> summary;

  /// Rekomendasi berdasarkan hasil
  final List<String> recommendations;

  /// Detail findings per kategori
  final Map<String, List<String>> categoryFindings;

  /// Overall score (0-100)
  final int score;

  /// Usia anak dalam bulan
  final int ageInMonths;

  /// Kategori usia (infant, toddler, preschool)
  final String ageCategory;

  /// Detail hasil per pertanyaan
  final Map<String, String> answerDetails;

  const FCResultModel({
    required this.riskLevel,
    required this.confidence,
    required this.derivedFacts,
    required this.triggeredRules,
    required this.summary,
    required this.recommendations,
    required this.categoryFindings,
    required this.score,
    required this.ageInMonths,
    required this.ageCategory,
    this.answerDetails = const {},
  });

  /// Konversi ke Map untuk API
  Map<String, dynamic> toMap() => {
    'riskLevel': riskLevel,
    'confidence': confidence,
    'derivedFacts': derivedFacts,
    'triggeredRules': triggeredRules,
    'summary': summary,
    'recommendations': recommendations,
    'categoryFindings': categoryFindings,
    'score': score,
    'ageInMonths': ageInMonths,
    'ageCategory': ageCategory,
    'answerDetails': answerDetails,
  };

  factory FCResultModel.fromMap(Map<String, dynamic> map) {
    return FCResultModel(
      riskLevel: map['riskLevel'] ?? 'LOW',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      derivedFacts: List<String>.from(map['derivedFacts'] ?? []),
      triggeredRules: List<String>.from(map['triggeredRules'] ?? []),
      summary: Map<String, dynamic>.from(map['summary'] ?? {}),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      categoryFindings: (map['categoryFindings'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ) ?? {},
      score: map['score'] ?? 0,
      ageInMonths: map['ageInMonths'] ?? 0,
      ageCategory: map['ageCategory'] ?? 'unknown',
      answerDetails: Map<String, String>.from(map['answerDetails'] ?? {}),
    );
  }

  /// Get color untuk risk level
  int get riskLevelColorValue {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return 0xFFEF4444; // Red
      case 'MEDIUM':
        return 0xFFFFB74D; // Orange
      case 'LOW':
      default:
        return 0xFF4CAF50; // Green
    }
  }

  /// Get display text untuk risk level
  String get riskLevelDisplay {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return 'Risiko Tinggi';
      case 'MEDIUM':
        return 'Risiko Sedang';
      case 'LOW':
      default:
        return 'Risiko Rendah';
    }
  }
}