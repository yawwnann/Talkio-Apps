import '../models/fc_rule_model.dart';

/// Forward Chaining Rules Knowledge Base
/// Berisi semua rules untuk deteksi speech delay berdasarkan WHO/DDST milestones

class FCRules {
  /// Get all rules
  static List<FCRuleModel> getAllRules() {
    return [
      ..._infantRules,
      ..._toddlerRules,
      ..._preschoolRules,
      ..._universalRules,
    ];
  }

  // ============ INFANT RULES (12-18 BULAN) ============
  static final List<FCRuleModel> _infantRules = [
    const FCRuleModel(
      id: 'inf_r001',
      name: 'Belum kata pertama usia 18+ bulan',
      antecedents: {
        'first_word': ['Belum', 'Tidak yakin'],
        '_ageInMonths': ['18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36'],
      },
      operator: 'AND',
      conclusion: 'belum_kata_pertama',
      confidence: 0.95,
      minAge: 18,
      maxAge: 999,
      category: 'speech',
      severityImpact: 2,
      recommendation: 'Usia 18+ bulan seharusnya sudah bisa mengucapkan kata pertama',
    ),
    const FCRuleModel(
      id: 'inf_r002',
      name: 'Belum kata pertama usia 24+ bulan (HIGH risk)',
      antecedents: {
        'first_word': ['Belum', 'Tidak yakin'],
        '_ageInMonths': ['24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60'],
      },
      operator: 'AND',
      conclusion: 'speech_delay_confirmed',
      confidence: 0.95,
      minAge: 24,
      maxAge: 999,
      category: 'speech',
      severityImpact: 3,
      recommendation: 'Keterlambatan bicara confirmed - segera konsultasikan dengan terapis',
    ),
    const FCRuleModel(
      id: 'inf_r003',
      name: 'Vocabulary sangat terbatas usia 18+ bulan',
      antecedents: {
        'vocabulary_count': ['Kurang dari 10', '0 kata', '1-3 kata'],
      },
      operator: 'AND',
      conclusion: 'vocabulary_terbatas',
      confidence: 0.9,
      minAge: 18,
      maxAge: 999,
      category: 'vocabulary',
      severityImpact: 2,
      recommendation: 'Kosakata sangat terbatas untuk usianya',
    ),
    const FCRuleModel(
      id: 'inf_r004',
      name: 'Tidak meniru suara sama sekali',
      antecedents: {
        'imitate_sounds': ['Tidak pernah', 'Jarang'],
      },
      operator: 'AND',
      conclusion: 'perkembangan_delayed',
      confidence: 0.85,
      minAge: 12,
      maxAge: 24,
      category: 'speech',
      severityImpact: 2,
      recommendation: 'Kemampuan meniru suara perlu stimulasi tambahan',
    ),
    const FCRuleModel(
      id: 'inf_r005',
      name: 'Respon nama buruk usia 12+ bulan',
      antecedents: {
        'name_response': ['Jarang', 'Tidak pernah'],
      },
      operator: 'AND',
      conclusion: 'respon_pendengaran_delayed',
      confidence: 0.9,
      minAge: 12,
      maxAge: 999,
      category: 'response',
      severityImpact: 3,
      recommendation: 'Perlu periksa pendengaran - kemungkinan masalah pendengaran',
    ),
  ];

  // ============ TODDLER RULES (18-36 BULAN) ============
  static final List<FCRuleModel> _toddlerRules = [
    const FCRuleModel(
      id: 'todd_r001',
      name: 'Belum kalimat 2 kata usia 24+ bulan',
      antecedents: {
        'two_word_phrase': ['Belum'],
      },
      operator: 'AND',
      conclusion: 'belum_kalimat_sederhana',
      confidence: 0.9,
      minAge: 24,
      maxAge: 999,
      category: 'speech',
      severityImpact: 2,
      recommendation: 'Seharusnya sudah bisa membuat kalimat 2 kata',
    ),
    const FCRuleModel(
      id: 'todd_r002',
      name: 'Speech clarity sangat buruk',
      antecedents: {
        'speech_clarity': ['Jarang', 'Tidak pernah'],
      },
      operator: 'AND',
      conclusion: 'artikulasi_delayed',
      confidence: 0.9,
      minAge: 18,
      maxAge: 999,
      category: 'articulation',
      severityImpact: 2,
      recommendation: 'Artikulasi perlu perhatian khusus - konsultasikan dengan terapis',
    ),
    const FCRuleModel(
      id: 'todd_r003',
      name: 'Tidak bisa ikuti perintah sederhana',
      antecedents: {
        'follow_commands': ['Belum'],
      },
      operator: 'AND',
      conclusion: 'perkembangan_delayed',
      confidence: 0.85,
      minAge: 18,
      maxAge: 36,
      category: 'comprehension',
      severityImpact: 2,
      recommendation: 'Kemampuan memahami perlu evaluasi lebih lanjut',
    ),
    const FCRuleModel(
      id: 'todd_r004',
      name: 'Vocabulary sangat kurang untuk usia',
      antecedents: {
        'vocabulary_count': ['Kurang dari 10'],
      },
      operator: 'AND',
      conclusion: 'speech_delay_confirmed',
      confidence: 0.95,
      minAge: 24,
      maxAge: 999,
      category: 'vocabulary',
      severityImpact: 3,
      recommendation: 'Speech delay confirmed - vocabulary sangat terbatas',
    ),
    const FCRuleModel(
      id: 'todd_r005',
      name: 'Respon nama buruk usia 18+ bulan',
      antecedents: {
        'name_response': ['Jarang', 'Tidak pernah'],
      },
      operator: 'AND',
      conclusion: 'respon_pendengaran_delayed',
      confidence: 0.95,
      minAge: 18,
      maxAge: 999,
      category: 'response',
      severityImpact: 3,
      recommendation: 'HIGH RISK: Kemungkinan masalah pendengaran',
    ),
    const FCRuleModel(
      id: 'todd_r006',
      name: 'Kekhawatiran orang tua tentang speech',
      antecedents: {
        'parent_concern': ['Ya'],
      },
      operator: 'AND',
      conclusion: 'perlu_monitoring',
      confidence: 0.8,
      minAge: 18,
      maxAge: 999,
      category: 'concern',
      severityImpact: 1,
      recommendation: 'Kekhawatiran orang tua perlu diperhatikan',
    ),
  ];

  // ============ PRESCHOOL RULES (36-60 BULAN) ============
  static final List<FCRuleModel> _preschoolRules = [
    const FCRuleModel(
      id: 'pres_r001',
      name: 'Vocabulary sangat kurang untuk usia 3-5 tahun',
      antecedents: {
        'vocabulary_count': ['Kurang dari 50'],
      },
      operator: 'AND',
      conclusion: 'vocabulary_terbatas',
      confidence: 0.9,
      minAge: 36,
      maxAge: 999,
      category: 'vocabulary',
      severityImpact: 2,
      recommendation: 'Vocabulary terbatas untuk usia prasekolah',
    ),
    const FCRuleModel(
      id: 'pres_r002',
      name: 'Belum bisa kalimat 3-4 kata usia 4+ tahun',
      antecedents: {
        'sentence_structure': ['Belum', 'Masih Belajar'],
      },
      operator: 'AND',
      conclusion: 'speech_delay_confirmed',
      confidence: 0.9,
      minAge: 48,
      maxAge: 999,
      category: 'speech',
      severityImpact: 3,
      recommendation: 'Keterlambatan speech confirmed - perlu intervensi segera',
    ),
    const FCRuleModel(
      id: 'pres_r003',
      name: 'Tidak bisa narasikan pengalaman',
      antecedents: {
        'narrative_skill': ['Belum'],
      },
      operator: 'AND',
      conclusion: 'perkembangan_delayed',
      confidence: 0.85,
      minAge: 36,
      maxAge: 999,
      category: 'language',
      severityImpact: 2,
      recommendation: 'Kemampuan narasi perlu stimulasi intensif',
    ),
    const FCRuleModel(
      id: 'pres_r004',
      name: 'Speech clarity sangat buruk di usia prasekolah',
      antecedents: {
        'speech_clarity': ['Jarang', 'Tidak pernah'],
      },
      operator: 'AND',
      conclusion: 'gangguan_artikulasi',
      confidence: 0.9,
      minAge: 36,
      maxAge: 999,
      category: 'articulation',
      severityImpact: 3,
      recommendation: 'HIGH RISK: Gangguan artikulasi - segera terapi',
    ),
    const FCRuleModel(
      id: 'pres_r005',
      name: 'Kesulitan artikulasi signifikan',
      antecedents: {
        'articulation_difficulty': ['Banyak', 'Sangat banyak'],
      },
      operator: 'AND',
      conclusion: 'gangguan_artikulasi',
      confidence: 0.95,
      minAge: 36,
      maxAge: 999,
      category: 'articulation',
      severityImpact: 3,
      recommendation: 'Gangguan artikulasi parah - segera konsultasikan',
    ),
    const FCRuleModel(
      id: 'pres_r006',
      name: 'Tidak bisa jawab pertanyaan sederhana',
      antecedents: {
        'answer_questions': ['Belum', 'Kadang-kadang'],
      },
      operator: 'AND',
      conclusion: 'perkembangan_delayed',
      confidence: 0.85,
      minAge: 36,
      maxAge: 999,
      category: 'comprehension',
      severityImpact: 2,
      recommendation: 'Pemahaman bahasa perlu stimulasi lebih',
    ),
    const FCRuleModel(
      id: 'pres_r007',
      name: 'Masalah sosial - sulit bergaul',
      antecedents: {
        'social_interaction': ['Sulit', 'Prefer sendiri'],
      },
      operator: 'AND',
      conclusion: 'perlu_evaluasi_sosial',
      confidence: 0.8,
      minAge: 36,
      maxAge: 999,
      category: 'social',
      severityImpact: 2,
      recommendation: 'Masalah interaksi sosial perlu perhatian',
    ),
  ];

  // ============ UNIVERSAL RULES (SEMUA USIA) ============
  static final List<FCRuleModel> _universalRules = [
    const FCRuleModel(
      id: 'univ_r001',
      name: 'Riwayat keluarga speech delay',
      antecedents: {
        'family_history': ['Ya'],
      },
      operator: 'AND',
      conclusion: 'faktor_risiko_genetik',
      confidence: 0.8,
      minAge: 0,
      maxAge: 999,
      category: 'history',
      severityImpact: 1,
      recommendation: 'Faktor genetik meningkatkan risiko speech delay',
    ),
    const FCRuleModel(
      id: 'univ_r002',
      name: 'Riwayat masalah pendengaran',
      antecedents: {
        'hearing_issues': ['Ya'],
      },
      operator: 'AND',
      conclusion: 'respon_pendengaran_delayed',
      confidence: 0.95,
      minAge: 0,
      maxAge: 999,
      category: 'medical',
      severityImpact: 3,
      recommendation: 'Riwayat pendengaran - prioritas tinggi untuk evaluasi THT',
    ),
    const FCRuleModel(
      id: 'univ_r003',
      name: 'Multiple delay indicators',
      antecedents: {
        'belum_kata_pertama': 'true',
        'vocabulary_terbatas': 'true',
      },
      operator: 'AND',
      conclusion: 'speech_delay_confirmed',
      confidence: 0.95,
      minAge: 0,
      maxAge: 999,
      category: 'speech',
      severityImpact: 3,
      recommendation: 'Multiple delay indicators - speech delay confirmed',
    ),
    const FCRuleModel(
      id: 'univ_r004',
      name: 'Respon pendengaran + artikulasi delay',
      antecedents: {
        'respon_pendengaran_delayed': 'true',
        'artikulasi_delayed': 'true',
      },
      operator: 'AND',
      conclusion: 'speech_delay_confirmed',
      confidence: 0.95,
      minAge: 0,
      maxAge: 999,
      category: 'speech',
      severityImpact: 3,
      recommendation: 'Speech delay dengan masalah pendengaran - prioritas tinggi',
    ),
    const FCRuleModel(
      id: 'univ_r005',
      name: 'Positive development indicators',
      antecedents: {
        'first_word': ['Ya'],
        'vocabulary_count': ['50-100 kata', '100-200 kata', '200-500 kata', 'Lebih dari 100', 'Lebih dari 500'],
        'speech_clarity': ['Selalu', 'Ya, dengan baik'],
      },
      operator: 'AND',
      conclusion: 'perkembangan_normal',
      confidence: 0.85,
      minAge: 18,
      maxAge: 999,
      category: 'speech',
      severityImpact: 0,
      recommendation: 'Indikator perkembangan positif',
    ),
  ];

  /// Get rules for specific age
  static List<FCRuleModel> getRulesForAge(int ageInMonths) {
    return getAllRules()
        .where((rule) => rule.isApplicableForAge(ageInMonths))
        .toList();
  }
}