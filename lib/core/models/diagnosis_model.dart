/// Diagnosis Model
/// Model untuk hasil diagnosis dan prediksi ML speech delay
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
  final MlPrediction? mlPrediction;

  DiagnosisModel({
    required this.id,
    required this.childId,
    required this.symptoms,
    required this.riskLevel,
    required this.score,
    this.recommendation,
    this.nextStep,
    required this.createdAt,
    this.mlPrediction,
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
      mlPrediction: json['mlPrediction'] != null || json['ml_prediction'] != null
          ? MlPrediction.fromJson(json['mlPrediction'] ?? json['ml_prediction'])
          : null,
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
      'mlPrediction': mlPrediction?.toJson(),
    };
  }

  @override
  String toString() {
    return 'DiagnosisModel(id: $id, riskLevel: $riskLevel, score: $score)';
  }
}

/// ML Prediction Model
class MlPrediction {
  final String id;
  final String? modelVersion;
  final double? predictionResult;
  final double? confidence;

  MlPrediction({
    required this.id,
    this.modelVersion,
    this.predictionResult,
    this.confidence,
  });

  factory MlPrediction.fromJson(Map<String, dynamic> json) {
    return MlPrediction(
      id: json['id'] ?? '',
      modelVersion: json['modelVersion'] ?? json['model_version'],
      predictionResult: json['predictionResult'] != null
          ? (json['predictionResult'] as num).toDouble()
          : null,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelVersion': modelVersion,
      'predictionResult': predictionResult,
      'confidence': confidence,
    };
  }
}
