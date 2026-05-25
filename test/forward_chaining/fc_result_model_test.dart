import 'package:flutter_test/flutter_test.dart';
import 'package:deteksi_telat_bicara/core/models/fc_result_model.dart';

void main() {
  group('FCResultModel - toMap / fromMap roundtrip', () {
    final result = FCResultModel(
      riskLevel: 'HIGH',
      confidence: 0.9,
      derivedFacts: ['belum_kata_pertama', 'speech_delay_confirmed'],
      triggeredRules: ['inf_r001', 'inf_r002'],
      summary: {
        'totalQuestions': 5,
        'derivedFacts': 2,
        'triggeredRules': 2,
        'delayIndicators': 2,
        'maxSeverity': 3,
        'ageCategory': 'Toddler',
      },
      recommendations: [
        'Disarankan segera berkonsultasi dengan terapis wicara',
        'Lakukan evaluasi pendengaran',
      ],
      categoryFindings: {
        'speech': ['Belum kata pertama'],
        'vocabulary': ['Vocabulary terbatas'],
      },
      score: 75,
      ageInMonths: 24,
      ageCategory: 'Toddler (Batita)',
      answerDetails: {
        'first_word': 'Belum',
        'vocabulary_count': '0 kata',
      },
    );

    test('toMap produces all fields correctly', () {
      final map = result.toMap();
      expect(map['riskLevel'], 'HIGH');
      expect(map['confidence'], 0.9);
      expect(map['score'], 75);
      expect(map['ageInMonths'], 24);
      expect(map['derivedFacts'], isA<List>());
      expect(map['recommendations'], isA<List>());
      expect(map['categoryFindings'], isA<Map>());
      expect(map['answerDetails'], isA<Map>());
    });

    test('fromMap reconstructs correctly', () {
      final map = result.toMap();
      final reconstructed = FCResultModel.fromMap(map);
      expect(reconstructed.riskLevel, result.riskLevel);
      expect(reconstructed.confidence, result.confidence);
      expect(reconstructed.score, result.score);
      expect(reconstructed.ageInMonths, result.ageInMonths);
      expect(reconstructed.derivedFacts, result.derivedFacts);
      expect(reconstructed.triggeredRules, result.triggeredRules);
      expect(reconstructed.recommendations, result.recommendations);
      expect(reconstructed.categoryFindings.keys, result.categoryFindings.keys);
      expect(reconstructed.answerDetails, result.answerDetails);
    });
  });

  group('FCResultModel - riskLevelDisplay', () {
    test('returns "Risiko Tinggi" for HIGH', () {
      final result = FCResultModel(
        riskLevel: 'HIGH',
        confidence: 0.9,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelDisplay, 'Risiko Tinggi');
    });

    test('returns "Risiko Sedang" for MEDIUM', () {
      final result = FCResultModel(
        riskLevel: 'MEDIUM',
        confidence: 0.7,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelDisplay, 'Risiko Sedang');
    });

    test('returns "Risiko Rendah" for LOW', () {
      final result = FCResultModel(
        riskLevel: 'LOW',
        confidence: 0.95,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelDisplay, 'Risiko Rendah');
    });
  });

  group('FCResultModel - riskLevelColorValue', () {
    test('returns red for HIGH', () {
      final result = FCResultModel(
        riskLevel: 'HIGH',
        confidence: 0.9,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelColorValue, 0xFFEF4444);
    });

    test('returns orange for MEDIUM', () {
      final result = FCResultModel(
        riskLevel: 'MEDIUM',
        confidence: 0.7,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelColorValue, 0xFFFFB74D);
    });

    test('returns green for LOW', () {
      final result = FCResultModel(
        riskLevel: 'LOW',
        confidence: 0.95,
        derivedFacts: [],
        triggeredRules: [],
        summary: {},
        recommendations: [],
        categoryFindings: {},
        score: 0,
        ageInMonths: 24,
        ageCategory: 'Toddler',
      );
      expect(result.riskLevelColorValue, 0xFF4CAF50);
    });
  });
}
