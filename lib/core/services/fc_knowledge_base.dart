import '../models/fc_question_model.dart';
import '../models/fc_rule_model.dart';

/// Forward Chaining Knowledge Base
/// Berisi semua pertanyaan dan rules untuk deteksi speech delay

class FCKnowledgeBase {
  /// Semua pertanyaan berdasarkan usia
  static List<FCQuestionModel> getAllQuestions() {
    return [
      // ============ INFANT (12-18 BULAN) ============
      ..._infantQuestions,

      // ============ TODDLER (18-36 BULAN) ============
      ..._toddlerQuestions,

      // ============ PRESCHOOL (36-60 BULAN) ============
      ..._preschoolQuestions,

      // ============ UNIVERSAL (SEMUA USIA) ============
      ..._universalQuestions,
    ];
  }

  /// Questions untuk infant (12-18 bulan)
  static final List<FCQuestionModel> _infantQuestions = [
    const FCQuestionModel(
      id: 'inf_001',
      question: 'Apakah anak Anda sudah bisa mengucapkan kata pertama?',
      options: ['Ya', 'Belum', 'Tidak yakin'],
      key: 'first_word',
      minAge: 12,
      maxAge: 18,
      category: 'speech',
      priority: 1,
      weight: 1.2,
    ),
    const FCQuestionModel(
      id: 'inf_002',
      question: 'Apakah anak meniru suara atau kata sederhana?',
      options: ['Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
      key: 'imitate_sounds',
      minAge: 12,
      maxAge: 18,
      category: 'speech',
      priority: 2,
      weight: 1.0,
    ),
    const FCQuestionModel(
      id: 'inf_003',
      question: 'Apakah anak merespons saat dipanggil namanya?',
      options: ['Selalu', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
      key: 'name_response',
      minAge: 12,
      maxAge: 18,
      category: 'response',
      priority: 1,
      weight: 1.3,
    ),
    const FCQuestionModel(
      id: 'inf_004',
      question: 'Berapa jumlah kata yang sudah bisa diucapkan anak?',
      options: ['0 kata', '1-3 kata', '4-10 kata', 'Lebih dari 10'],
      key: 'vocabulary_count',
      minAge: 12,
      maxAge: 18,
      category: 'vocabulary',
      priority: 1,
      weight: 1.5,
    ),
    const FCQuestionModel(
      id: 'inf_005',
      question: 'Apakah anak menggunakan gerakan tangan untuk berkomunikasi?',
      options: ['Ya, sering', 'Kadang-kadang', 'Jarang', 'Tidak'],
      key: 'gesture_comm',
      minAge: 12,
      maxAge: 18,
      category: 'communication',
      priority: 3,
      weight: 0.8,
    ),
  ];

  /// Questions untuk toddler (18-36 bulan)
  static final List<FCQuestionModel> _toddlerQuestions = [
    const FCQuestionModel(
      id: 'todd_001',
      question: 'Apakah anak sudah bisa mengucapkan kata pertama?',
      options: ['Ya', 'Belum', 'Tidak yakin'],
      key: 'first_word',
      minAge: 18,
      maxAge: 36,
      category: 'speech',
      priority: 1,
      weight: 1.3,
    ),
    const FCQuestionModel(
      id: 'todd_002',
      question: 'Berapa jumlah kata yang sudah bisa diucapkan anak?',
      options: ['Kurang dari 10', '10-50 kata', '50-100 kata', '100-200 kata', 'Lebih dari 100'],
      key: 'vocabulary_count',
      minAge: 18,
      maxAge: 36,
      category: 'vocabulary',
      priority: 1,
      weight: 1.5,
    ),
    const FCQuestionModel(
      id: 'todd_003',
      question: 'Apakah anak bisa membuat kalimat 2 kata?',
      options: ['Ya', 'Kadang-kadang', 'Belum'],
      key: 'two_word_phrase',
      minAge: 18,
      maxAge: 36,
      category: 'speech',
      priority: 2,
      weight: 1.2,
    ),
    const FCQuestionModel(
      id: 'todd_004',
      question: 'Apakah orang lain bisa memahami ucapan anak Anda?',
      options: ['Selalu', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
      key: 'speech_clarity',
      minAge: 18,
      maxAge: 36,
      category: 'articulation',
      priority: 1,
      weight: 1.4,
    ),
    const FCQuestionModel(
      id: 'todd_005',
      question: 'Apakah anak merespons saat dipanggil namanya?',
      options: ['Selalu', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
      key: 'name_response',
      minAge: 18,
      maxAge: 36,
      category: 'response',
      priority: 1,
      weight: 1.3,
    ),
    const FCQuestionModel(
      id: 'todd_006',
      question: 'Apakah anak menanyakan nama benda di sekitarnya?',
      options: ['Ya, sering', 'Kadang-kadang', 'Jarang', 'Tidak'],
      key: 'ask_names',
      minAge: 24,
      maxAge: 36,
      category: 'communication',
      priority: 3,
      weight: 0.9,
    ),
    const FCQuestionModel(
      id: 'todd_007',
      question: 'Apakah anak bisa mengikuti perintah sederhana?',
      options: ['Ya', 'Kadang-kadang', 'Belum'],
      key: 'follow_commands',
      minAge: 18,
      maxAge: 36,
      category: 'comprehension',
      priority: 2,
      weight: 1.1,
    ),
    const FCQuestionModel(
      id: 'todd_008',
      question: 'Apakah anak menunjukkan interesse saat dibacakan cerita?',
      options: ['Ya, sangat', 'Ya', 'Kadang-kadang', 'Tidak'],
      key: 'interest_reading',
      minAge: 18,
      maxAge: 36,
      category: 'social',
      priority: 3,
      weight: 0.8,
    ),
  ];

  /// Questions untuk preschool (36-60 bulan)
  static final List<FCQuestionModel> _preschoolQuestions = [
    const FCQuestionModel(
      id: 'pres_001',
      question: 'Berapa jumlah kata yang sudah bisa diucapkan anak?',
      options: ['Kurang dari 50', '50-200 kata', '200-500 kata', 'Lebih dari 500'],
      key: 'vocabulary_count',
      minAge: 36,
      maxAge: 60,
      category: 'vocabulary',
      priority: 1,
      weight: 1.5,
    ),
    const FCQuestionModel(
      id: 'pres_002',
      question: 'Apakah anak bisa membuat kalimat 3-4 kata yang runut?',
      options: ['Ya, dengan baik', 'Ya, kadang salah', 'Masih Belajar', 'Belum'],
      key: 'sentence_structure',
      minAge: 36,
      maxAge: 60,
      category: 'speech',
      priority: 1,
      weight: 1.4,
    ),
    const FCQuestionModel(
      id: 'pres_003',
      question: 'Apakah anak bisa menceritakan pengalaman hariannya?',
      options: ['Ya, detail', 'Ya, singkat', 'Kadang-kadang', 'Belum'],
      key: 'narrative_skill',
      minAge: 36,
      maxAge: 60,
      category: 'language',
      priority: 2,
      weight: 1.2,
    ),
    const FCQuestionModel(
      id: 'pres_004',
      question: 'Apakah orang lain bisa memahami ucapan anak Anda?',
      options: ['Selalu', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
      key: 'speech_clarity',
      minAge: 36,
      maxAge: 60,
      category: 'articulation',
      priority: 1,
      weight: 1.4,
    ),
    const FCQuestionModel(
      id: 'pres_005',
      question: 'Apakah anak bisa menjawab pertanyaan sederhana?',
      options: ['Ya, dengan baik', 'Ya', 'Kadang-kadang', 'Belum'],
      key: 'answer_questions',
      minAge: 36,
      maxAge: 60,
      category: 'comprehension',
      priority: 2,
      weight: 1.1,
    ),
    const FCQuestionModel(
      id: 'pres_006',
      question: 'Apakah anak bisa menyebut warna dan angka?',
      options: ['Ya', 'Sebagian', 'Sedikit', 'Belum'],
      key: 'color_numbers',
      minAge: 36,
      maxAge: 60,
      category: 'vocabulary',
      priority: 3,
      weight: 1.0,
    ),
    const FCQuestionModel(
      id: 'pres_007',
      question: 'Apakah anak memiliki kesulitan mengucapkan huruf tertentu?',
      options: ['Tidak ada', 'Sedikit', 'Banyak', 'Sangat banyak'],
      key: 'articulation_difficulty',
      minAge: 36,
      maxAge: 60,
      category: 'articulation',
      priority: 2,
      weight: 1.3,
    ),
    const FCQuestionModel(
      id: 'pres_008',
      question: 'Apakah anak bisa bermain dengan anak lain?',
      options: ['Ya, baik', 'Ya, kadang konflik', 'Sulit', 'Prefer sendiri'],
      key: 'social_interaction',
      minAge: 36,
      maxAge: 60,
      category: 'social',
      priority: 2,
      weight: 1.0,
    ),
  ];

  /// Universal questions (semua usia)
  static final List<FCQuestionModel> _universalQuestions = [
    const FCQuestionModel(
      id: 'univ_001',
      question: 'Apakah ada riwayat keterlambatan bicara dalam keluarga?',
      options: ['Ya', 'Tidak', 'Tidak tahu'],
      key: 'family_history',
      minAge: 0,
      maxAge: 999,
      category: 'history',
      priority: 4,
      weight: 0.9,
    ),
    const FCQuestionModel(
      id: 'univ_002',
      question: 'Apakah anak pernah mengalami masalah pendengaran?',
      options: ['Ya', 'Tidak', 'Tidak yakin'],
      key: 'hearing_issues',
      minAge: 0,
      maxAge: 999,
      category: 'medical',
      priority: 2,
      weight: 1.5,
    ),
    const FCQuestionModel(
      id: 'univ_003',
      question: 'Apakah ada kekhawatiran khusus dari orang tua/guru?',
      options: ['Ya', 'Tidak yakin', 'Tidak'],
      key: 'parent_concern',
      minAge: 0,
      maxAge: 999,
      category: 'concern',
      priority: 3,
      weight: 1.0,
    ),
  ];

  /// Get questions untuk usia tertentu
  static List<FCQuestionModel> getQuestionsForAge(int ageInMonths) {
    final allQuestions = getAllQuestions();
    return allQuestions
        .where((q) => q.isRelevantForAge(ageInMonths))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Get categories untuk usia tertentu
  static List<String> getCategoriesForAge(int ageInMonths) {
    final questions = getQuestionsForAge(ageInMonths);
    return questions.map((q) => q.category).toSet().toList();
  }
}