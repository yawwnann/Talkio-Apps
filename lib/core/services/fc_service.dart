import '../models/fc_result_model.dart';
import '../models/fc_question_model.dart';
import 'fc_knowledge_base.dart';
import 'fc_rules.dart';
import 'fc_inference_engine.dart';

/// Forward Chaining Service
/// Service utama untuk menjalankan forward chaining diagnosis

class FCService {
  /// Get questions berdasarkan usia anak
  List<FCQuestionModel> getQuestionsForAge(int ageInMonths) {
    return FCKnowledgeBase.getQuestionsForAge(ageInMonths);
  }

  /// Run diagnosis dengan forward chaining
  FCResultModel runDiagnosis({
    required Map<String, String> answers,
    required int ageInMonths,
  }) {
    // Get applicable rules for age
    final rules = FCRules.getRulesForAge(ageInMonths);

    // Create inference engine with rules
    final engine = FCInferenceEngine(rules: rules);

    // Run forward chaining
    final result = engine.infer(answers, ageInMonths);

    return result;
  }

  /// Get milestone info berdasarkan usia
  Map<String, dynamic> getMilestoneInfo(int ageInMonths) {
    if (ageInMonths < 18) {
      return {
        'category': 'Infant (Bayi)',
        'ageRange': '12-18 bulan',
        'milestones': [
          'Mengucapkan kata pertama',
          'Meniru suara dan kata sederhana',
          'Merespons saat dipanggil nama',
          'Memahami perintah sederhana',
        ],
        'warningSigns': [
          'Belum ada kata sama sekali',
          'Tidak merespons suara',
          'Tidak meniru suara',
        ],
      };
    } else if (ageInMonths < 36) {
      return {
        'category': 'Toddler (Batita)',
        'ageRange': '18-36 bulan',
        'milestones': [
          'Kosakata 10-50 kata',
          'Membuat kalimat 2 kata',
          'Memahami perintah lebih kompleks',
          'Menanyakan nama benda',
        ],
        'warningSigns': [
          'Kosakata kurang dari 10 kata',
          'Belum bisa kalimat 2 kata',
          'Ucapan tidak jelas',
        ],
      };
    } else {
      return {
        'category': 'Preschool (Prasekolah)',
        'ageRange': '36-60 bulan',
        'milestones': [
          'Kosakata 200+ kata',
          'Kalimat 3-4 kata',
          'Menceritakan pengalaman',
          'Bermain dengan anak lain',
        ],
        'warningSigns': [
          'Kosakata terbatas',
          'Struktur kalimat tidak правильний',
          'Masalah sosial',
        ],
      };
    }
  }

  /// Get answer options untuk pertanyaan tertentu
  List<String> getAnswerOptions(String questionId) {
    final questions = FCKnowledgeBase.getAllQuestions();
    final question = questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => const FCQuestionModel(
        id: '',
        question: '',
        options: [],
        key: '',
      ),
    );
    return question.options;
  }

  /// Get question by key
  FCQuestionModel? getQuestionByKey(String key, int ageInMonths) {
    final questions = getQuestionsForAge(ageInMonths);
    try {
      return questions.firstWhere((q) => q.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Validate answers completeness
  Map<String, dynamic> validateAnswers(
    Map<String, String> answers,
    int ageInMonths,
  ) {
    final questions = getQuestionsForAge(ageInMonths);
    final unansweredQuestions = <String>[];
    final answeredQuestions = <String>[];

    for (var question in questions) {
      if (answers.containsKey(question.key)) {
        answeredQuestions.add(question.key);
      } else if (question.category != 'history' && question.category != 'concern') {
        // Optional questions are history and concern
        unansweredQuestions.add(question.question);
      }
    }

    return {
      'isComplete': unansweredQuestions.isEmpty,
      'answeredCount': answeredQuestions.length,
      'totalCount': questions.length,
      'unansweredQuestions': unansweredQuestions,
    };
  }

  /// Generate summary text dari result
  String generateSummaryText(FCResultModel result) {
    final buffer = StringBuffer();

    buffer.writeln('📊 Hasil Assessment');
    buffer.writeln('═══════════════════════════');
    buffer.writeln();

    buffer.writeln('📅 Usia Anak: ${result.ageInMonths} bulan');
    buffer.writeln('🏷️ Kategori: ${result.ageCategory}');
    buffer.writeln('📈 Skor: ${result.score}%');
    buffer.writeln('⚠️ Risk Level: ${result.riskLevelDisplay}');
    buffer.writeln();

    buffer.writeln('📋 Temuan per Kategori:');
    for (var entry in result.categoryFindings.entries) {
      buffer.writeln('  • ${entry.key.toUpperCase()}:');
      for (var finding in entry.value) {
        buffer.writeln('    - $finding');
      }
    }
    buffer.writeln();

    buffer.writeln('💡 Rekomendasi:');
    for (var rec in result.recommendations) {
      buffer.writeln('  ✓ $rec');
    }

    return buffer.toString();
  }
}