import 'package:flutter_test/flutter_test.dart';
import 'package:deteksi_telat_bicara/core/models/fc_rule_model.dart';
import 'package:deteksi_telat_bicara/core/services/fc_inference_engine.dart';

void main() {
  group('FCInferenceEngine - empty rules', () {
    test('returns LOW risk with empty rules and no answers', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({}, 24);
      expect(result.riskLevel, 'LOW');
      expect(result.score, 0);
      expect(result.derivedFacts, isEmpty);
      expect(result.triggeredRules, isEmpty);
    });
  });

  group('FCInferenceEngine - single rule inference', () {
    final rules = [
      const FCRuleModel(
        id: 'test_r001',
        name: 'Test rule',
        antecedents: {'first_word': 'Belum'},
        conclusion: 'belum_kata_pertama',
        minAge: 0,
        maxAge: 999,
        category: 'speech',
        severityImpact: 2,
        confidence: 0.9,
      ),
    ];

    test('derives fact when antecedent is satisfied', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'first_word': 'Belum'}, 24);
      expect(result.derivedFacts, contains('belum_kata_pertama'));
      expect(result.triggeredRules, contains('test_r001'));
    });

    test('does not derive fact when antecedent is not satisfied', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'first_word': 'Ya'}, 24);
      expect(result.derivedFacts, isEmpty);
      expect(result.triggeredRules, isEmpty);
    });

    test('risk level is MEDIUM when delay indicator >= 1', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'first_word': 'Belum'}, 24);
      expect(result.riskLevel, 'MEDIUM');
      expect(result.score, greaterThan(0));
    });
  });

  group('FCInferenceEngine - chaining (multiple rules)', () {
    final rules = [
      const FCRuleModel(
        id: 'chain_r001',
        name: 'Chain rule 1',
        antecedents: {'q1': 'yes'},
        conclusion: 'fact_a',
        minAge: 0,
        maxAge: 999,
        category: 'speech',
        severityImpact: 1,
        confidence: 0.8,
      ),
      const FCRuleModel(
        id: 'chain_r002',
        name: 'Chain rule 2',
        antecedents: {'fact_a': 'true'},
        conclusion: 'fact_b',
        minAge: 0,
        maxAge: 999,
        category: 'vocabulary',
        severityImpact: 2,
        confidence: 0.9,
      ),
      const FCRuleModel(
        id: 'chain_r003',
        name: 'Chain rule 3',
        antecedents: {'fact_b': 'true'},
        conclusion: 'speech_delay_confirmed',
        minAge: 0,
        maxAge: 999,
        category: 'speech',
        severityImpact: 3,
        confidence: 0.95,
      ),
    ];

    test('forward chaining derives fact_b and speech_delay_confirmed from q1=yes', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q1': 'yes'}, 24);
      expect(result.derivedFacts, contains('fact_a'));
      expect(result.derivedFacts, contains('fact_b'));
      expect(result.derivedFacts, contains('speech_delay_confirmed'));
      expect(result.triggeredRules, hasLength(3));
    });

    test('risk level is HIGH when speech_delay_confirmed with severity 3', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q1': 'yes'}, 24);
      expect(result.riskLevel, 'HIGH');
      expect(result.score, greaterThan(0));
    });

    test('derived facts do NOT include facts that are in working memory', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q1': 'yes', 'fact_a': 'no'}, 24);
      // fact_a is already in working memory, so it won't be in derivedFacts
      expect(result.derivedFacts, isNot(contains('fact_a')));
    });
  });

  group('FCInferenceEngine - age restricted rules', () {
    final infantRule = const FCRuleModel(
      id: 'infant_only',
      name: 'Infant only rule',
      antecedents: {'crying': 'Ya'},
      conclusion: 'infant_finding',
      minAge: 0,
      maxAge: 18,
      category: 'speech',
      severityImpact: 1,
      confidence: 0.8,
    );

    final toddlerRule = const FCRuleModel(
      id: 'toddler_only',
      name: 'Toddler only rule',
      antecedents: {'crying': 'Ya'},
      conclusion: 'toddler_finding',
      minAge: 18,
      maxAge: 36,
      category: 'speech',
      severityImpact: 1,
      confidence: 0.8,
    );

    test('infant rule fires for 12-month-old, toddler rule does not', () {
      final engine = FCInferenceEngine(rules: [infantRule, toddlerRule]);
      final result = engine.infer({'crying': 'Ya'}, 12);
      expect(result.derivedFacts, contains('infant_finding'));
      expect(result.derivedFacts, isNot(contains('toddler_finding')));
    });

    test('toddler rule fires for 24-month-old, infant rule does not', () {
      final engine = FCInferenceEngine(rules: [infantRule, toddlerRule]);
      final result = engine.infer({'crying': 'Ya'}, 24);
      expect(result.derivedFacts, contains('toddler_finding'));
      expect(result.derivedFacts, isNot(contains('infant_finding')));
    });

    test('neither rule fires for 60-month-old', () {
      final engine = FCInferenceEngine(rules: [infantRule, toddlerRule]);
      final result = engine.infer({'crying': 'Ya'}, 60);
      expect(result.derivedFacts, isEmpty);
    });
  });

  group('FCInferenceEngine - category findings', () {
    final rules = [
      const FCRuleModel(
        id: 'cat_r001',
        name: 'Speech rule',
        antecedents: {'q': 'a'},
        conclusion: 'speech_finding',
        minAge: 0,
        maxAge: 999,
        category: 'speech',
        severityImpact: 1,
        confidence: 0.8,
      ),
      const FCRuleModel(
        id: 'cat_r002',
        name: 'Vocabulary rule',
        antecedents: {'q': 'a'},
        conclusion: 'vocab_finding',
        minAge: 0,
        maxAge: 999,
        category: 'vocabulary',
        severityImpact: 1,
        confidence: 0.8,
      ),
    ];

    test('groups findings by category', () {
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q': 'a'}, 24);
      expect(result.categoryFindings.keys, contains('speech'));
      expect(result.categoryFindings.keys, contains('vocabulary'));
      expect(result.categoryFindings['speech']!.length, greaterThan(0));
      expect(result.categoryFindings['vocabulary']!.length, greaterThan(0));
    });
  });

  group('FCInferenceEngine - recommendations', () {
    test('HIGH risk returns therapy recommendations', () {
      final rules = [
        const FCRuleModel(
          id: 'high_r001',
          name: 'High severity rule',
          antecedents: {'q': 'a'},
          conclusion: 'speech_delay_confirmed',
          minAge: 0,
          maxAge: 999,
          category: 'speech',
          severityImpact: 3,
          confidence: 0.95,
        ),
      ];
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q': 'a'}, 24);
      expect(result.riskLevel, 'HIGH');
      expect(result.recommendations.any((r) => r.contains('konsultasi')), isTrue);
      expect(result.recommendations.any((r) => r.contains('terapi')), isTrue);
    });

    test('MEDIUM risk returns monitoring recommendations', () {
      final rules = [
        const FCRuleModel(
          id: 'med_r001',
          name: 'Medium severity rule',
          antecedents: {'q': 'a'},
          conclusion: 'belum_kata_pertama',
          minAge: 0,
          maxAge: 999,
          category: 'speech',
          severityImpact: 2,
          confidence: 0.8,
        ),
      ];
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q': 'a'}, 24);
      expect(result.riskLevel, 'MEDIUM');
      expect(result.recommendations.any((r) => r.contains('monitoring')), isTrue);
    });

    test('LOW risk returns normal development recommendations', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({}, 24);
      expect(result.riskLevel, 'LOW');
      expect(result.recommendations.any((r) => r.contains('normal')), isTrue);
    });
  });

  group('FCInferenceEngine - age category', () {
    test('returns Infant for age < 18 months', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({}, 12);
      expect(result.ageCategory, contains('Infant'));
    });

    test('returns Toddler for age 18-35 months', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({}, 24);
      expect(result.ageCategory, contains('Toddler'));
    });

    test('returns Preschool for age >= 36 months', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({}, 48);
      expect(result.ageCategory, contains('Preschool'));
    });
  });

  group('FCInferenceEngine - summary', () {
    test('summary contains totalQuestions, derivedFacts, triggeredRules', () {
      final rules = [
        const FCRuleModel(
          id: 's_r001',
          name: 'Summary test',
          antecedents: {'q': 'a'},
          conclusion: 'test_fact',
          minAge: 0,
          maxAge: 999,
          category: 'speech',
          severityImpact: 1,
          confidence: 0.8,
        ),
      ];
      final engine = FCInferenceEngine(rules: rules);
      final result = engine.infer({'q': 'a', 'q2': 'b'}, 24);
      // totalQuestions = answers.length (2) + derivedFacts (1) = 3, minus _ageInMonths = 2
      expect(result.summary['totalQuestions'], 3);
      expect(result.summary['derivedFacts'], greaterThan(0));
      expect(result.summary['triggeredRules'], greaterThan(0));
      expect(result.summary['ageCategory'], isNotEmpty);
    });
  });

  group('FCInferenceEngine - answerDetails', () {
    test('answerDetails excludes _ageInMonths', () {
      final engine = FCInferenceEngine(rules: []);
      final result = engine.infer({'q1': 'Ya', 'q2': 'Tidak'}, 24);
      expect(result.answerDetails, containsPair('q1', 'Ya'));
      expect(result.answerDetails, containsPair('q2', 'Tidak'));
      expect(result.answerDetails, isNot(contains('_ageInMonths')));
    });
  });
}
