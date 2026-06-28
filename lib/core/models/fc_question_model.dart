/// Forward Chaining Question Model
/// Model untuk pertanyaan yang memiliki rentang usia

class FCQuestionModel {
  /// Unique identifier untuk pertanyaan
  final String id;

  /// Teks pertanyaan
  final String question;

  /// Opsi jawaban yang tersedia
  final List<String> options;

  /// Key untuk menyimpan jawaban
  final String key;

  /// Usia minimum dalam bulan (0 = tidak terbatas)
  final int minAge;

  /// Usia maksimum dalam bulan (999 = tidak terbatas)
  final int maxAge;

  /// Kategori pertanyaan (speech, vocabulary, response, dll)
  final String category;

  /// Prioritas pertanyaan (1 = tertinggi)
  final int priority;

  /// Bobot untuk perhitungan skor (default 1.0)
  final double weight;

  const FCQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.key,
    this.minAge = 0,
    this.maxAge = 999,
    this.category = 'general',
    this.priority = 5,
    this.weight = 1.0,
  });

  /// Cek apakah pertanyaan relevan untuk usia tertentu
  bool isRelevantForAge(int ageInMonths) {
    return ageInMonths >= minAge && ageInMonths <= maxAge;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'key': key,
    'minAge': minAge,
    'maxAge': maxAge,
    'category': category,
    'priority': priority,
    'weight': weight,
  };

  factory FCQuestionModel.fromJson(Map<String, dynamic> json) {
    return FCQuestionModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      key: json['key'] ?? '',
      minAge: json['minAge'] ?? 0,
      maxAge: json['maxAge'] ?? 999,
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 5,
      weight: (json['weight'] ?? 1.0).toDouble(),
    );
  }
}