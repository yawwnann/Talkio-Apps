/// Diagnosis Model
/// Model untuk hasil diagnosis dari Forward Chaining Engine
/// Matches backend API response format dengan comprehensive results

class DiagnosisModel {
  final String id;
  final String childId;

  // Forward Chaining Results
  final Map<String, String> answers;          // Jawaban pertanyaan
  final int ageInMonths;                        // Usia anak dalam bulan
  final String ageCategory;                     // Kategori usia
  final String riskLevel;                      // LOW, MEDIUM, HIGH
  final double confidence;                      // Confidence score (0-1)
  final int score;                             // Skor dalam persen (0-100)

  // Inference Details
  final List<String> derivedFacts;             // Fakta yang diturunkan
  final List<String> triggeredRules;          // Rules yang dipicu
  final Map<String, List<String>> findings;    // Temuan per kategori
  final List<String> recommendations;           // Rekomendasi
  final String? summary;                       // Ringkasan text

  final DateTime createdAt;

  DiagnosisModel({
    required this.id,
    required this.childId,
    required this.answers,
    required this.ageInMonths,
    required this.ageCategory,
    required this.riskLevel,
    required this.confidence,
    required this.score,
    required this.derivedFacts,
    required this.triggeredRules,
    required this.findings,
    required this.recommendations,
    this.summary,
    required this.createdAt,
  });

  // Get risk level color value
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

  // Get risk level display text
  String get riskLevelDisplay {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return 'Risiko Tinggi';
      case 'MEDIUM':
        return 'Risiko Sedang';
      case 'LOW':
        return 'Risiko Rendah';
      default:
        return riskLevel;
    }
  }

  // Get risk level description
  String get riskLevelDescription {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return 'Perkembangan speech anak terlihat normal. Lanjutkan stimulasi di rumah.';
      case 'MEDIUM':
        return 'Ada beberapa area yang perlu perhatian. Disarankan konsultasi dengan terapis.';
      case 'HIGH':
        return 'Anak memerlukan evaluasi dan terapi speech delay segera.';
      default:
        return '';
    }
  }

  // Get severity label
  String get severityLabel {
    if (derivedFacts.length >= 3 || triggeredRules.length >= 3) {
      return 'Severe';
    } else if (derivedFacts.isNotEmpty || triggeredRules.isNotEmpty) {
      return 'Moderate';
    }
    return 'Normal';
  }

  // Convert from JSON - matches new backend response format
  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    // Parse findings - can be List or Map
    Map<String, List<String>> parsedFindings = {};
    if (json['findings'] != null) {
      if (json['findings'] is Map) {
        (json['findings'] as Map).forEach((key, value) {
          if (value is List) {
            parsedFindings[key.toString()] = value.map((e) => e.toString()).toList();
          }
        });
      }
    }

    // Parse recommendations
    List<String> parsedRecommendations = [];
    if (json['recommendations'] != null) {
      if (json['recommendations'] is List) {
        parsedRecommendations = (json['recommendations'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Parse derivedFacts
    List<String> parsedDerivedFacts = [];
    if (json['derivedFacts'] != null) {
      if (json['derivedFacts'] is List) {
        parsedDerivedFacts = (json['derivedFacts'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Parse triggeredRules
    List<String> parsedTriggeredRules = [];
    if (json['triggeredRules'] != null) {
      if (json['triggeredRules'] is List) {
        parsedTriggeredRules = (json['triggeredRules'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Parse answers
    Map<String, String> parsedAnswers = {};
    if (json['answers'] != null && json['answers'] is Map) {
      (json['answers'] as Map).forEach((key, value) {
        parsedAnswers[key.toString()] = value.toString();
      });
    }

    return DiagnosisModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? json['child_id'] ?? '',
      answers: parsedAnswers,
      ageInMonths: json['ageInMonths'] ?? 0,
      ageCategory: json['ageCategory'] ?? 'Unknown',
      riskLevel: json['riskLevel'] ?? json['risk_level'] ?? 'LOW',
      confidence: (json['confidence'] ?? 0.95).toDouble(),
      score: json['score'] ?? 0,
      derivedFacts: parsedDerivedFacts,
      triggeredRules: parsedTriggeredRules,
      findings: parsedFindings,
      recommendations: parsedRecommendations,
      summary: json['summary']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'answers': answers,
      'ageInMonths': ageInMonths,
      'ageCategory': ageCategory,
      'riskLevel': riskLevel,
      'confidence': confidence,
      'score': score,
      'derivedFacts': derivedFacts,
      'triggeredRules': triggeredRules,
      'findings': findings,
      'recommendations': recommendations,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiagnosisModel(id: $id, riskLevel: $riskLevel, score: $score%, age: $ageInMonths months)';
  }
}