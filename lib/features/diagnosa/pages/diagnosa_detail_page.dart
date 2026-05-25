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
                      _buildAnalysisCard(),
                      const SizedBox(height: 16),
                      if (_diagnosis!.findings.isNotEmpty) _buildFindingsCard(),
                      if (_diagnosis!.findings.isNotEmpty) const SizedBox(height: 16),
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

  Widget _buildAnalysisCard() {
    final d = _diagnosis!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Analisis'),
          const SizedBox(height: 12),
          if (d.ageCategory.isNotEmpty) _detailRow('Kategori Usia', d.ageCategory),
          if (d.derivedFacts.isNotEmpty) _detailRow('Fakta Terdeteksi', d.derivedFacts.join(', ')),
          if (d.triggeredRules.isNotEmpty) _detailRow('Rules Terpicu', '${d.triggeredRules.length} rule(s)'),
          if (d.summary != null) _detailRow('Ringkasan', d.summary!),
        ],
      ),
    );
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
                      Expanded(child: Text(finding, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)))),
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
                  Expanded(child: Text(e.value, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF475569)))),
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
