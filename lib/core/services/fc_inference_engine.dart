import '../models/fc_rule_model.dart';
import '../models/fc_result_model.dart';

/// Forward Chaining Inference Engine
/// Implementasi algoritma forward chaining untuk deteksi speech delay

class FCInferenceEngine {
  /// Knowledge base rules
  final List<FCRuleModel> rules;

  FCInferenceEngine({required this.rules});

  /// Execute forward chaining algorithm
  /// Input: facts (jawaban pertanyaan)
  /// Output: FCResultModel (hasil diagnosis)
  FCResultModel infer(
    Map<String, String> answers,
    int ageInMonths,
  ) {
    // Create working memory (facts)
    final Map<String, String> workingMemory = Map.from(answers);
    workingMemory['_ageInMonths'] = ageInMonths.toString();

    // Track derived facts
    final Set<String> derivedFacts = <String>{};

    // Track triggered rules
    final List<String> triggeredRules = <String>[];

    // Track category findings
    final Map<String, List<String>> categoryFindings = <String, List<String>>{};

    // Forward chaining loop - iterate until no new facts discovered
    bool newFactsFound;
    do {
      newFactsFound = false;

      for (var rule in rules) {
        // Skip if rule is age-restricted and doesn't apply
        if (!rule.isApplicableForAge(ageInMonths)) {
          continue;
        }

        // Skip if rule already triggered
        if (triggeredRules.contains(rule.id)) {
          continue;
        }

        // Check if rule can trigger
        if (rule.canTrigger(workingMemory)) {
          // Fire the rule - add conclusion to working memory
          if (!workingMemory.containsKey(rule.conclusion)) {
            workingMemory[rule.conclusion] = 'true';
            derivedFacts.add(rule.conclusion);
            triggeredRules.add(rule.id);

            // Add to category findings
            final category = rule.category;
            if (!categoryFindings.containsKey(category)) {
              categoryFindings[category] = [];
            }
            (categoryFindings[category]!).add(
              '${rule.name}: ${rule.conclusion}',
            );

            newFactsFound = true;
          }
        }
      }
    } while (newFactsFound);

    // Calculate final results
    return _calculateResults(
      workingMemory: workingMemory,
      derivedFacts: derivedFacts,
      triggeredRules: triggeredRules,
      categoryFindings: categoryFindings,
      ageInMonths: ageInMonths,
    );
  }

  /// Calculate final results from working memory
  FCResultModel _calculateResults({
    required Map<String, String> workingMemory,
    required Set<String> derivedFacts,
    required List<String> triggeredRules,
    required Map<String, List<String>> categoryFindings,
    required int ageInMonths,
  }) {
    // Calculate delay indicators count
    final delayIndicators = _getDelayIndicators();
    int delayCount = 0;
    List<String> delaySymptoms = [];

    for (var fact in derivedFacts) {
      if (fact.endsWith('_kurang') || fact.endsWith('_delayed') || delayIndicators.contains(fact)) {
        delayCount++;
        delaySymptoms.add(fact);
      }
    }

    // Get triggered rules for severity calculation
    final activeSeverities = rules
        .where((r) => triggeredRules.contains(r.id))
        .map((r) => r.severityImpact)
        .toList();

    final maxSeverity = activeSeverities.isEmpty
        ? 0
        : activeSeverities.reduce((a, b) => a > b ? a : b);

    // Calculate weighted score
    double score = 0;
    double maxScore = 0;

    for (var rule in rules.where((r) => triggeredRules.contains(r.id))) {
      score += rule.confidence * rule.severityImpact;
      maxScore += 1.0 * 3; // max confidence = 1.0, max severity = 3
    }

    final normalizedScore = maxScore > 0 ? (score / maxScore) : 0.0;
    final percentScore = (normalizedScore * 100).clamp(0, 100).toInt();

    // Determine risk level
    String riskLevel;
    double confidence;

    if (delayCount >= 3 || maxSeverity >= 3) {
      riskLevel = 'HIGH';
      confidence = 0.9;
    } else if (delayCount >= 1 || maxSeverity >= 2) {
      riskLevel = 'MEDIUM';
      confidence = 0.7;
    } else {
      riskLevel = 'LOW';
      confidence = 0.95;
    }

    // Generate recommendations
    final recommendations = _generateRecommendations(
      derivedFacts: derivedFacts,
      triggerRules: triggeredRules,
      ageInMonths: ageInMonths,
      riskLevel: riskLevel,
    );

    // Get age category
    final ageCategory = _getAgeCategory(ageInMonths);

    // Summary
    final summary = <String, dynamic>{
      'totalQuestions': workingMemory.length - 1, // exclude _ageInMonths
      'derivedFacts': derivedFacts.length,
      'triggeredRules': triggeredRules.length,
      'delayIndicators': delayCount,
      'maxSeverity': maxSeverity,
      'ageCategory': ageCategory,
    };

    // Answer details for display
    final answerDetails = Map<String, String>.from(workingMemory)
      ..remove('_ageInMonths');

    return FCResultModel(
      riskLevel: riskLevel,
      confidence: confidence,
      derivedFacts: derivedFacts.toList(),
      triggeredRules: triggeredRules,
      summary: summary,
      recommendations: recommendations,
      categoryFindings: categoryFindings,
      score: percentScore,
      ageInMonths: ageInMonths,
      ageCategory: ageCategory,
      answerDetails: answerDetails,
    );
  }

  /// Get list of delay indicators
  List<String> _getDelayIndicators() {
    return [
      'belum_kata_pertama',
      'vocabulary_terbatas',
      'belum_kalimat_sederhana',
      'artikulasi_delayed',
      'respon_pendengaran_delayed',
      'speech_delay_confirmed',
      'perkembangan_delayed',
      'gangguan_artikulasi',
    ];
  }

  /// Generate recommendations based on findings
  List<String> _generateRecommendations({
    required Set<String> derivedFacts,
    required List<String> triggerRules,
    required int ageInMonths,
    required String riskLevel,
  }) {
    final recommendations = <String>[];


    if (riskLevel == 'HIGH') {
      recommendations.addAll([
        'Disarankan segera berkonsultasi dengan terapis wicara',
        'Lakukan evaluasi pendengaran untuk memastikan fungsiPendengaran',
        'Mulai program terapi wicara secepat mungkin',
      ]);

      if (derivedFacts.contains('respon_pendengaran_delayed')) {
        recommendations.add('Segera lakukan periksa pendengaran dengan THT');
      }

      if (derivedFacts.contains('gangguan_artikulasi')) {
        recommendations.add('Fokus pada latihan artikulasi dengan terapis');
      }
    } else if (riskLevel == 'MEDIUM') {
      recommendations.addAll([
        'Disarankan melakukan monitoring perkembangan secara rutin',
        'Lakukan stimulasi speech di rumah secara konsisten',
        'Konsultasi dengan terapis wicara untuk penilaian lebih lanjut',
      ]);

      if (ageInMonths < 24) {
        recommendations.add('Fokus pada stimulasi bicara dengan meniru suara');
      }
    } else {
      recommendations.addAll([
        'Perkembangan speech anak terlihat normal',
        'Lanjutkan stimulasi di rumah dengan aktivitas bicara sehari-hari',
        'Lakukan evaluasi berkala setiap 6 bulan',
      ]);
    }

    // Universal recommendations
    recommendations.add('Buat lingkungan yang kayastimulasi bicara di rumah');

    return recommendations;
  }

  /// Get age category name
  String _getAgeCategory(int ageInMonths) {
    if (ageInMonths < 18) {
      return 'Infant (Bayi)';
    } else if (ageInMonths < 36) {
      return 'Toddler (Batita)';
    } else if (ageInMonths < 60) {
      return 'Preschool (Prasekolah)';
    } else {
      return 'Preschool+(Prasekolah+)';
    }
  }
}