import 'package:flutter_test/flutter_test.dart';
import 'package:deteksi_telat_bicara/core/services/fc_service.dart';
import 'package:deteksi_telat_bicara/core/models/fc_question_model.dart';

void main() {
  group('FCService - getQuestionsForAge', () {
    final service = FCService();

    test('returns questions for infant (12 months)', () {
      final questions = service.getQuestionsForAge(12);
      expect(questions, isNotEmpty);
      // Infant questions should include age-appropriate milestones
      expect(questions.any((q) => q.key == 'first_word'), isTrue);
    });

    test('returns questions for toddler (24 months)', () {
      final questions = service.getQuestionsForAge(24);
      expect(questions, isNotEmpty);
      // Toddler questions should include two_word_phrase
      expect(questions.any((q) => q.key == 'two_word_phrase'), isTrue);
    });

    test('returns questions for preschool (48 months)', () {
      final questions = service.getQuestionsForAge(48);
      expect(questions, isNotEmpty);
    });

    test('question format is valid', () {
      final questions = service.getQuestionsForAge(24);
      for (final q in questions) {
        expect(q.id, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options, isNotEmpty);
        expect(q.key, isNotEmpty);
        expect(q.category, isNotEmpty);
      }
    });
  });

  group('FCService - runDiagnosis', () {
    final service = FCService();

    test('HIGH risk when multiple severe symptoms at 24 months', () {
      final answers = {
        'first_word': 'Belum',
        'vocabulary_count': '0 kata',
        'imitate_sounds': 'Tidak pernah',
        'name_response': 'Jarang',
      };
      final result = service.runDiagnosis(answers: answers, ageInMonths: 24);
      expect(result.riskLevel, 'HIGH');
      expect(result.score, greaterThan(50));
      expect(result.recommendations, isNotEmpty);
    });

    test('LOW risk when no symptoms at 24 months', () {
      final answers = {
        'first_word': 'Ya',
        'vocabulary_count': 'Lebih dari 50',
        'imitate_sounds': 'Sering',
        'name_response': 'Ya',
      };
      final result = service.runDiagnosis(answers: answers, ageInMonths: 24);
      expect(result.riskLevel, 'LOW');
      expect(result.score, lessThan(50));
      expect(result.recommendations, isNotEmpty);
    });

    test('age 12 months with no symptoms returns LOW', () {
      final answers = {
        'first_word': 'Ya',
        'imitate_sounds': 'Sering',
        'name_response': 'Ya',
        'vocabulary_count': '1-3 kata',
      };
      final result = service.runDiagnosis(answers: answers, ageInMonths: 12);
      expect(result.riskLevel, 'LOW');
    });

    test('age 12 months with severe symptoms returns HIGH', () {
      final answers = {
        'first_word': 'Belum',
        'imitate_sounds': 'Tidak pernah',
        'name_response': 'Tidak pernah',
      };
      final result = service.runDiagnosis(answers: answers, ageInMonths: 12);
      expect(result.riskLevel, 'HIGH');
    });
  });

  group('FCService - getMilestoneInfo', () {
    final service = FCService();

    test('returns infant milestones for age < 18 months', () {
      final info = service.getMilestoneInfo(12);
      expect(info['category'], contains('Infant'));
      expect(info['milestones'], isNotEmpty);
      expect(info['warningSigns'], isNotEmpty);
    });

    test('returns toddler milestones for age 18-35 months', () {
      final info = service.getMilestoneInfo(24);
      expect(info['category'], contains('Toddler'));
      expect(info['milestones'], isNotEmpty);
      expect(info['warningSigns'], isNotEmpty);
    });

    test('returns preschool milestones for age >= 36 months', () {
      final info = service.getMilestoneInfo(48);
      expect(info['category'], contains('Preschool'));
      expect(info['milestones'], isNotEmpty);
      expect(info['warningSigns'], isNotEmpty);
    });
  });

  group('FCService - validateAnswers', () {
    final service = FCService();

    test('returns isComplete true when all essential questions answered', () {
      final questions = service.getQuestionsForAge(24);
      final answers = <String, String>{};
      for (final q in questions) {
        if (q.category != 'history' && q.category != 'concern') {
          answers[q.key] = q.options.first;
        }
      }
      final result = service.validateAnswers(answers, 24);
      expect(result['isComplete'], isTrue);
      expect(result['answeredCount'], greaterThan(0));
    });

    test('returns isComplete false when essential questions missing', () {
      final result = service.validateAnswers({}, 24);
      expect(result['isComplete'], isFalse);
      expect(result['answeredCount'], 0);
      expect(result['unansweredQuestions'], isNotEmpty);
    });

    test('totalCount matches number of questions for the age', () {
      final questions = service.getQuestionsForAge(24);
      final result = service.validateAnswers({}, 24);
      expect(result['totalCount'], questions.length);
    });
  });

  group('FCService - getAnswerOptions', () {
    final service = FCService();

    test('returns options for existing question id', () {
      // Get a known question first
      final questions = service.getQuestionsForAge(24);
      expect(questions, isNotEmpty);

      final options = service.getAnswerOptions(questions.first.id);
      expect(options, isNotEmpty);
    });

    test('returns empty list for non-existent question id', () {
      final options = service.getAnswerOptions('non_existent_id');
      expect(options, isEmpty);
    });
  });

  group('FCService - getQuestionByKey', () {
    final service = FCService();

    test('returns question for existing key', () {
      final question = service.getQuestionByKey('first_word', 24);
      expect(question, isNotNull);
      expect(question!.key, 'first_word');
    });

    test('returns null for non-existent key', () {
      final question = service.getQuestionByKey('non_existent', 24);
      expect(question, isNull);
    });
  });

  group('FCService - generateSummaryText', () {
    final service = FCService();

    test('returns non-empty summary for any result', () {
      final result = service.runDiagnosis(answers: {}, ageInMonths: 24);
      final summary = service.generateSummaryText(result);
      expect(summary, isNotEmpty);
      expect(summary, contains('Hasil Assessment'));
      expect(summary, contains('Risk Level'));
    });
  });
}
