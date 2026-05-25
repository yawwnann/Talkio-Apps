/// Forward Chaining Rule Model
/// Model untuk aturan inference dalam sistem pakar

class FCRuleModel {
  /// Unique identifier untuk aturan
  final String id;

  /// Nama aturan (untuk debugging)
  final String name;

  /// Kondisi antecedent (fakta yang harus terpenuhi)
  /// Format: {'key': 'value'} atau {'key': ['value1', 'value2']}
  final Map<String, dynamic> antecedents;

  /// Operator untuk multiple antecedents
  /// 'AND' = semua antecedent harus terpenuhi
  /// 'OR' = salah satu antecedent harus terpenuhi
  final String operator;

  /// Kesimpulan yang ditarik jika rule aktif
  final String conclusion;

  /// Confidence factor (0.0 - 1.0)
  final double confidence;

  /// Usia minimum dalam bulan untuk rule ini (0 = semua usia)
  final int minAge;

  /// Usia maksimum dalam bulan (999 = semua usia)
  final int maxAge;

  /// Kategori rule (speech, vocabulary, response, dll)
  final String category;

  /// Severity impact: 1=low, 2=medium, 3=high
  final int severityImpact;

  /// Rekomendasi jika rule aktif
  final String? recommendation;

  const FCRuleModel({
    required this.id,
    required this.name,
    required this.antecedents,
    this.operator = 'AND',
    required this.conclusion,
    this.confidence = 1.0,
    this.minAge = 0,
    this.maxAge = 999,
    this.category = 'general',
    this.severityImpact = 1,
    this.recommendation,
  });

  /// Cek apakah rule applicable untuk usia tertentu
  bool isApplicableForAge(int ageInMonths) {
    return ageInMonths >= minAge && ageInMonths <= maxAge;
  }

  /// Cek apakah rule dapat di-trigger berdasarkan facts
  bool canTrigger(Map<String, String> facts) {
    if (!isApplicableForAge(_getAgeFromFacts(facts))) {
      return false;
    }

    if (operator == 'AND') {
      return _checkAllAntecedents(facts);
    } else {
      return _checkAnyAntecedent(facts);
    }
  }

  bool _checkAllAntecedents(Map<String, String> facts) {
    for (var entry in antecedents.entries) {
      final key = entry.key;
      final expectedValues = entry.value;

      if (!facts.containsKey(key)) {
        return false;
      }

      final actualValue = facts[key]!;

      if (expectedValues is List) {
        if (!expectedValues.contains(actualValue)) {
          return false;
        }
      } else {
        if (expectedValues.toString() != actualValue) {
          return false;
        }
      }
    }
    return true;
  }

  bool _checkAnyAntecedent(Map<String, String> facts) {
    for (var entry in antecedents.entries) {
      final key = entry.key;
      final expectedValues = entry.value;

      if (!facts.containsKey(key)) {
        continue;
      }

      final actualValue = facts[key]!;

      if (expectedValues is List) {
        if (expectedValues.contains(actualValue)) {
          return true;
        }
      } else {
        if (expectedValues.toString() == actualValue) {
          return true;
        }
      }
    }
    return false;
  }

  int _getAgeFromFacts(Map<String, String> facts) {
    if (facts.containsKey('_ageInMonths')) {
      return int.tryParse(facts['_ageInMonths']!) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'antecedents': antecedents,
    'operator': operator,
    'conclusion': conclusion,
    'confidence': confidence,
    'minAge': minAge,
    'maxAge': maxAge,
    'category': category,
    'severityImpact': severityImpact,
    'recommendation': recommendation,
  };

  factory FCRuleModel.fromJson(Map<String, dynamic> json) {
    return FCRuleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      antecedents: Map<String, dynamic>.from(json['antecedents'] ?? {}),
      operator: json['operator'] ?? 'AND',
      conclusion: json['conclusion'] ?? '',
      confidence: (json['confidence'] ?? 1.0).toDouble(),
      minAge: json['minAge'] ?? 0,
      maxAge: json['maxAge'] ?? 999,
      category: json['category'] ?? 'general',
      severityImpact: json['severityImpact'] ?? 1,
      recommendation: json['recommendation'],
    );
  }
}