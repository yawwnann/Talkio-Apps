import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/diagnosis_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/diagnosis_model.dart';

class DiagnosaDetailPage extends ConsumerStatefulWidget {
  final String diagnosisId;

  const DiagnosaDetailPage({super.key, required this.diagnosisId});

  @override
  ConsumerState<DiagnosaDetailPage> createState() => _DiagnosaDetailPageState();
}

class _DiagnosaDetailPageState extends ConsumerState<DiagnosaDetailPage> {
  DiagnosisModel? _diagnosis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ref.read(diagnosisProvider.notifier).getDiagnosisById(widget.diagnosisId);
    if (mounted) {
      setState(() {
        _diagnosis = result;
        _isLoading = false;
      });
    }
  }

  Color get _riskColor => Color(_diagnosis?.riskLevelColorValue ?? 0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppConstants.primaryBlue),
        title: Text(
          'Detail Diagnosa',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diagnosis == null
              ? Center(child: Text('Data tidak ditemukan', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildScoreCard(),
                      const SizedBox(height: 16),
                      _buildFindingsCard(),
                      const SizedBox(height: 16),
                      _buildRecommendationsCard(),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final d = _diagnosis!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_riskColor.withValues(alpha: 0.8), _riskColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            d.riskLevel == 'HIGH' ? Icons.warning_rounded
                : d.riskLevel == 'MEDIUM' ? Icons.info_outline_rounded
                : Icons.check_circle_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            d.riskLevelDisplay,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            d.riskLevelDescription,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Skor: ${d.score}%  |  ${d.ageCategory}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final d = _diagnosis!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Skor Diagnosa'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scoreItem('${d.score}%', 'Skor', _riskColor),
              _scoreItem('${(d.confidence * 100).toInt()}%', 'Confidence', AppConstants.primaryBlue),
              _scoreItem('${d.derivedFacts.length}', 'Fakta', const Color(0xFFFFB74D)),
              _scoreItem('${d.triggeredRules.length}', 'Rules', const Color(0xFF9C27B0)),
            ],
          ),
          if (d.ageCategory.isNotEmpty) ...[            
            const SizedBox(height: 12),
            _detailRow('Kategori Usia', d.ageCategory),
          ],
          if (d.summary != null && d.summary!.isNotEmpty) ...[            
            const SizedBox(height: 4),
            _buildSummarySection(d.summary!),
          ],
        ],
      ),
    );
  }

  Widget _scoreItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildSummarySection(String summaryJson) {
    try {
      // Parse JSON string summary
      Map<String, dynamic> summary;
      if (summaryJson.startsWith('{')) {
        summary = jsonDecode(summaryJson) as Map<String, dynamic>;
      } else {
        summary = {'summary': summaryJson};
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.entries.map<Widget>((entry) {
                  final value = entry.value;
                  if (value is int) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getSummaryIcon(entry.key),
                            size: 16,
                            color: AppConstants.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_formatSummaryKey(entry.key)}: $value',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      // If parsing fails, show as plain text
      return _detailRow('Ringkasan', summaryJson);
    }
  }

  IconData _getSummaryIcon(String key) {
    switch (key.toLowerCase()) {
      case 'total':
        return Icons.analytics;
      case 'speech':
        return Icons.record_voice_over;
      case 'vocabulary':
        return Icons.library_books;
      case 'articulation':
        return Icons.speaker;
      case 'response':
        return Icons.touch_app;
      case 'communication':
        return Icons.chat;
      default:
        return Icons.info_outline;
    }
  }

  String _formatSummaryKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatFinding(String finding) {
    if (!finding.contains(' - ')) return finding;
    
    final parts = finding.split(' - ');
    String variable = parts[0].trim();
    String status = parts[1].trim();

    if (status.endsWith('_baik')) {
      status = 'Baik';
    } else if (status.endsWith('_cukup')) {
      status = 'Cukup';
    } else if (status.endsWith('_kurang')) {
      status = 'Kurang';
    } else if (status.endsWith('_terlambat')) {
      status = 'Terlambat';
    } else if (status == 'tidak_ada_risiko_genetik') {
      status = 'Tidak ada risiko';
    } else if (status == 'ada_risiko_genetik') {
      status = 'Ada risiko';
    } else if (status == 'pantau_ringan') {
      status = 'Pantau ringan';
    } else if (status == 'perlu_evaluasi') {
      status = 'Perlu evaluasi';
    } else if (status == 'tidak_ada_masalah_pendengaran') {
      status = 'Tidak ada masalah';
    } else if (status == 'ada_indikasi_masalah_pendengaran') {
      status = 'Ada indikasi masalah';
    } else {
      status = status.replaceAll(variable, '');
      status = status.replaceAll(RegExp(r'^_\d+_'), ''); 
      status = status.replaceAll(RegExp(r'^_'), ''); 
      status = status.replaceAll('_', ' ');
    }

    final Map<String, String> mapping = {
      "first_word": "kata pertama",
      "imitate_sounds": "meniru suara",
      "vocabulary_count_12": "jumlah kosa kata",
      "vocabulary_count_24": "jumlah kosa kata",
      "vocabulary_count_36": "jumlah kosa kata",
      "vocabulary_count_48": "jumlah kosa kata",
      "vocabulary_count_60": "kosa kata",
      "vocabulary_count": "kosa kata",
      "name_response": "respon panggilan",
      "gesture_comm": "komunikasi dengan gerakan",
      "understand_simple": "pemahaman perintah sederhana",
      "babbling": "mengoceh",
      "attention_sounds": "perhatian pada suara",
      "two_word_phrase": "frasa dua kata",
      "speech_clarity_24": "kejelasan bicara",
      "speech_clarity_36": "kejelasan bicara",
      "speech_clarity_48": "kejelasan bicara",
      "speech_clarity_60": "kejelasan bicara",
      "speech_clarity": "kejelasan bicara",
      "asking_what": "bertanya 'apa'",
      "follow_commands_two": "mengikuti dua perintah",
      "point_body_parts": "menunjuk bagian tubuh",
      "uses_i_me": "penggunaan 'saya'/'aku'",
      "enjoy_stories": "ketertarikan cerita",
      "three_word_sentence": "kalimat tiga kata",
      "asking_why_how": "bertanya 'mengapa/bagaimana'",
      "follow_commands_three": "mengikuti tiga perintah",
      "understand_prepositions": "pemahaman kata depan",
      "uses_plurals_past": "penggunaan bentuk kata",
      "tells_simple_story": "bercerita sederhana",
      "complex_sentences": "kalimat kompleks",
      "articulation_difficulty_48": "artikulasi",
      "articulation_difficulty_60": "artikulasi",
      "articulation_difficulty": "artikulasi",
      "understand_concept": "pemahaman konsep dasar",
      "answer_w_questions": "menjawab pertanyaan",
      "tell_experiences": "menceritakan pengalaman",
      "rhyming_words": "pemahaman kata berima",
      "story_structure": "struktur cerita",
      "follow_rules": "mengikuti aturan",
      "complex_questions": "menjawab pertanyaan kompleks",
      "speech_comparison": "kemampuan bicara vs sebaya",
      "express_feelings": "mengekspresikan perasaan",
      "narrative_skill": "kemampuan naratif",
      "asking_why": "bertanya 'mengapa'",
      "color_recognition": "mengenal warna",
      "family_history": "riwayat keluarga",
      "parent_concern": "kekhawatiran orangtua",
      "eye_contact": "kontak mata",
      "pointing": "menunjuk",
      "show_objects": "menunjukkan objek",
      "joint_attention": "perhatian bersama",
      "play_skills": "keterampilan bermain",
      "hearing_test": "tes pendengaran",
      "ear_infection": "infeksi telinga",
      "pretend_play": "bermain pura-pura",
      "hearing_issues": "masalah pendengaran",
      "social_smile": "senyum sosial"
    };

    String translatedVariable = mapping[variable] ?? variable;
    if (translatedVariable.isNotEmpty) {
      translatedVariable = translatedVariable[0].toUpperCase() + translatedVariable.substring(1);
    }
    if (status.isNotEmpty) {
      status = status[0].toUpperCase() + status.substring(1);
    }

    return '$translatedVariable: $status';
  }

  Widget _buildFindingsCard() {
    final d = _diagnosis!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Temuan per Kategori'),
          const SizedBox(height: 12),
          ...d.findings.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabel(entry.key),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.primaryBlue),
                ),
                const SizedBox(height: 4),
                ...entry.value.map((finding) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
                      Expanded(child: Text(_formatFinding(finding), style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)))),
                    ],
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _translateRecommendation(String text) {
    final Map<String, String> mapping = {
      "first_word": "kata pertama",
      "imitate_sounds": "meniru suara",
      "vocabulary_count_12": "jumlah kosa kata",
      "name_response": "respon terhadap panggilan nama",
      "gesture_comm": "komunikasi dengan gerakan",
      "understand_simple": "pemahaman perintah sederhana",
      "babbling": "mengoceh",
      "attention_sounds": "perhatian pada suara",
      "vocabulary_count_24": "jumlah kosa kata",
      "two_word_phrase": "penggunaan frasa dua kata",
      "speech_clarity_24": "kejelasan bicara",
      "asking_what": "bertanya menggunakan kata 'apa'",
      "follow_commands_two": "mengikuti dua perintah sekaligus",
      "point_body_parts": "menunjuk bagian tubuh",
      "uses_i_me": "penggunaan kata 'saya' atau 'aku'",
      "enjoy_stories": "ketertarikan pada cerita",
      "vocabulary_count_36": "jumlah kosa kata",
      "three_word_sentence": "penggunaan kalimat tiga kata",
      "speech_clarity_36": "kejelasan bicara",
      "asking_why_how": "bertanya menggunakan kata 'mengapa' atau 'bagaimana'",
      "follow_commands_three": "mengikuti tiga perintah sekaligus",
      "understand_prepositions": "pemahaman kata depan",
      "uses_plurals_past": "penggunaan bentuk kata yang sesuai",
      "tells_simple_story": "bercerita sederhana",
      "vocabulary_count_48": "jumlah kosa kata",
      "complex_sentences": "penggunaan kalimat kompleks",
      "speech_clarity_48": "kejelasan bicara",
      "articulation_difficulty_48": "artikulasi",
      "understand_concept": "pemahaman konsep dasar",
      "answer_w_questions": "menjawab pertanyaan sederhana",
      "tell_experiences": "menceritakan pengalaman",
      "rhyming_words": "pemahaman kata-kata berima",
      "vocabulary_count_60": "kosa kata",
      "story_structure": "menyusun struktur cerita",
      "speech_clarity_60": "kejelasan bicara",
      "articulation_difficulty_60": "artikulasi",
      "follow_rules": "mengikuti aturan",
      "complex_questions": "menjawab pertanyaan kompleks",
      "speech_comparison": "kemampuan bicara dibandingkan sebaya",
      "express_feelings": "mengekspresikan perasaan",
      "narrative_skill": "kemampuan naratif",
      "asking_why": "bertanya menggunakan kata 'mengapa'",
      "color_recognition": "mengenal warna"
    };

    String result = text;
    mapping.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  Widget _buildRecommendationsCard() {
    final d = _diagnosis!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Rekomendasi'),
          const SizedBox(height: 12),
          if (d.recommendations.isEmpty)
            Text('Tidak ada rekomendasi khusus', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)))
          else
            ...d.recommendations.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: AppConstants.successColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('${e.key + 1}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppConstants.successColor))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_translateRecommendation(e.value), style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569)))),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final d = _diagnosis!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Informasi'),
          const SizedBox(height: 12),
          _detailRow('ID Diagnosa', d.id),
          _detailRow('Tanggal', '${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}'),
          _detailRow('Usia', '${d.ageInMonths} bulan'),
          _detailRow('Jumlah Jawaban', '${d.answers.length} pertanyaan'),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569)))),
        ],
      ),
    );
  }

  String _categoryLabel(String key) {
    const labels = {
      'vocabulary': 'Kosakata',
      'articulation': 'Artikulasi',
      'response': 'Responsivitas',
      'communication': 'Komunikasi',
      'social': 'Sosial',
      'motor': 'Motorik',
      'cognitive': 'Kognitif',
      'hearing': 'Pendengaran',
      'general': 'Umum',
    };
    return labels[key] ?? key;
  }
}
