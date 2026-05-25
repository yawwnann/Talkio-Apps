import 'package:flutter_test/flutter_test.dart';
import 'package:deteksi_telat_bicara/core/models/fc_rule_model.dart';

void main() {
  group('FCRuleModel - isApplicableForAge', () {
    final rule = const FCRuleModel(
      id: 'test_r001',
      name: 'Test rule',
      antecedents: {'first_word': 'Belum'},
      conclusion: 'belum_kata_pertama',
      minAge: 18,
      maxAge: 36,
    );

    test('returns true when age is within range', () {
      expect(rule.isApplicableForAge(18), isTrue);
      expect(rule.isApplicableForAge(24), isTrue);
      expect(rule.isApplicableForAge(36), isTrue);
    });

    test('returns false when age is below minAge', () {
      expect(rule.isApplicableForAge(0), isFalse);
      expect(rule.isApplicableForAge(12), isFalse);
      expect(rule.isApplicableForAge(17), isFalse);
    });

    test('returns false when age is above maxAge', () {
      expect(rule.isApplicableForAge(37), isFalse);
      expect(rule.isApplicableForAge(60), isFalse);
    });

    test('default range (0-999) applies to all ages', () {
      const defaultRule = FCRuleModel(
        id: 'test_r002',
        name: 'Default range rule',
        antecedents: {'key': 'value'},
        conclusion: 'test',
      );
      expect(defaultRule.isApplicableForAge(0), isTrue);
      expect(defaultRule.isApplicableForAge(12), isTrue);
      expect(defaultRule.isApplicableForAge(60), isTrue);
      expect(defaultRule.isApplicableForAge(999), isTrue);
    });
  });

  group('FCRuleModel - canTrigger (AND operator)', () {
    final rule = const FCRuleModel(
      id: 'test_and',
      name: 'AND rule',
      antecedents: {
        'first_word': 'Belum',
        'vocabulary_count': 'Kurang dari 10',
      },
      operator: 'AND',
      conclusion: 'test_conclusion',
      minAge: 0,
      maxAge: 999,
    );

    test('returns true when all antecedents match', () {
      final facts = {
        'first_word': 'Belum',
        'vocabulary_count': 'Kurang dari 10',
        '_ageInMonths': '24',
      };
      expect(rule.canTrigger(facts), isTrue);
    });

    test('returns false when one antecedent does not match', () {
      final facts = {
        'first_word': 'Belum',
        'vocabulary_count': 'Lebih dari 50',
        '_ageInMonths': '24',
      };
      expect(rule.canTrigger(facts), isFalse);
    });

    test('returns false when a required fact is missing', () {
      final facts = {
        'first_word': 'Belum',
        '_ageInMonths': '24',
      };
      expect(rule.canTrigger(facts), isFalse);
    });
  });

  group('FCRuleModel - canTrigger (OR operator)', () {
    final rule = const FCRuleModel(
      id: 'test_or',
      name: 'OR rule',
      antecedents: {
        'first_word': ['Belum', 'Tidak yakin'],
      },
      operator: 'OR',
      conclusion: 'test_conclusion',
      minAge: 0,
      maxAge: 999,
    );

    test('returns true when any antecedent matches', () {
      expect(rule.canTrigger({'first_word': 'Belum', '_ageInMonths': '24'}), isTrue);
      expect(rule.canTrigger({'first_word': 'Tidak yakin', '_ageInMonths': '24'}), isTrue);
    });

    test('returns false when no antecedent matches', () {
      expect(rule.canTrigger({'first_word': 'Ya', '_ageInMonths': '24'}), isFalse);
    });
  });

  group('FCRuleModel - canTrigger age restricted', () {
    final rule = const FCRuleModel(
      id: 'test_age',
      name: 'Age restricted rule',
      antecedents: {'first_word': 'Belum'},
      conclusion: 'test',
      minAge: 18,
      maxAge: 36,
    );

    test('returns true when facts trigger and age is valid', () {
      expect(rule.canTrigger({'first_word': 'Belum', '_ageInMonths': '24'}), isTrue);
    });

    test('returns false when age is outside range even if facts match', () {
      expect(rule.canTrigger({'first_word': 'Belum', '_ageInMonths': '12'}), isFalse);
      expect(rule.canTrigger({'first_word': 'Belum', '_ageInMonths': '48'}), isFalse);
    });
  });

  group('FCRuleModel - list antecedent values', () {
    final rule = const FCRuleModel(
      id: 'test_list',
      name: 'List antecedent rule',
      antecedents: {
        'vocabulary_count': ['0 kata', '1-3 kata', 'Kurang dari 10'],
      },
      conclusion: 'vocabulary_terbatas',
      minAge: 0,
      maxAge: 999,
    );

    test('matches any value in the list', () {
      expect(rule.canTrigger({'vocabulary_count': '0 kata', '_ageInMonths': '24'}), isTrue);
      expect(rule.canTrigger({'vocabulary_count': 'Kurang dari 10', '_ageInMonths': '24'}), isTrue);
    });

    test('does not match value outside the list', () {
      expect(rule.canTrigger({'vocabulary_count': 'Lebih dari 50', '_ageInMonths': '24'}), isFalse);
    });
  });

  group('FCRuleModel - toJson / fromJson roundtrip', () {
    final rule = const FCRuleModel(
      id: 'test_json',
      name: 'JSON test',
      antecedents: {'key': 'value'},
      operator: 'AND',
      conclusion: 'test',
      confidence: 0.85,
      minAge: 12,
      maxAge: 36,
      category: 'speech',
      severityImpact: 2,
      recommendation: 'Test recommendation',
    );

    test('toJson produces correct map', () {
      final json = rule.toJson();
      expect(json['id'], 'test_json');
      expect(json['name'], 'JSON test');
      expect(json['conclusion'], 'test');
      expect(json['confidence'], 0.85);
      expect(json['minAge'], 12);
      expect(json['maxAge'], 36);
      expect(json['category'], 'speech');
      expect(json['severityImpact'], 2);
    });

    test('fromJson reconstructs correctly', () {
      final json = rule.toJson();
      final reconstructed = FCRuleModel.fromJson(json);
      expect(reconstructed.id, rule.id);
      expect(reconstructed.name, rule.name);
      expect(reconstructed.conclusion, rule.conclusion);
      expect(reconstructed.confidence, rule.confidence);
      expect(reconstructed.minAge, rule.minAge);
      expect(reconstructed.maxAge, rule.maxAge);
    });
  });
}
