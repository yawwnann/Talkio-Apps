import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/models/anak_model.dart';
import '../providers/fc_konsultasi_provider.dart';
import '../../../core/models/fc_question_model.dart';
import '../../../core/models/diagnosis_model.dart';
import '../../../core/services/api_service.dart';

/// Konsultasi Page dengan Forward Chaining
/// Halaman konsultasi menggunakan sistem pakar forward chaining
class KonsultasiPage extends ConsumerStatefulWidget {
  const KonsultasiPage({super.key});

  @override
  ConsumerState<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends ConsumerState<KonsultasiPage> {
  int _currentStep = 0;
  AnakModel? _selectedAnak;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcKonsultasiProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final konsultasiState = ref.watch(fcKonsultasiProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: SimpleAppBar(
          title: 'Deteksi Speech Delay',
          onBackPress: () => context.go('/dashboard'),
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            // Content
            Expanded(child: _buildStepContent(konsultasiState)),

            // Navigation Buttons
            _buildNavigationButtons(konsultasiState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Pilih Anak', 'Pertanyaan', 'Hasil'];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppConstants.primaryBlue
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isActive && index < _currentStep
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isCurrent
                                ? AppConstants.primaryBlue
                                : Colors.grey,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: index < _currentStep
                            ? AppConstants.primaryBlue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(FCKonsultasiState state) {
    switch (_currentStep) {
      case 0:
        return _buildSelectChildStep();
      case 1:
        return _buildQuestionsStep(state);
      case 2:
        return _buildResultStep(state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSelectChildStep() {
    final anakList = ref.watch(anakProvider.select((s) => s.anakList));
    final isLoading = ref.watch(anakProvider.select((s) => s.isLoading));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryBlue, AppConstants.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Anak',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Pilih anak yang akan dikonsultasikan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppConstants.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pertanyaan akan disesuaikan dengan usia anak untuk hasil yang lebih akurat.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Child List
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (anakList.isEmpty)
            _buildEmptyChildState()
          else
            ...anakList.map((anak) => _buildChildCard(anak)),
        ],
      ),
    );
  }

  Widget _buildEmptyChildState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data anak',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan data anak terlebih dahulu',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/anak/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
            ),
            child: const Text('Tambah Anak'),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(AnakModel anak) {
    final isSelected = _selectedAnak?.id == anak.id;
    final age = _calculateAge(anak.dateOfBirth);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedAnak = anak);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: anak.gender == 'L'
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.child_care,
                color: anak.gender == 'L'
                    ? const Color(0xFF1976D2)
                    : const Color(0xFFC2185B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anak.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$age tahun (${anak.ageInMonths} bulan)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsStep(FCKonsultasiState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card with Age
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAnak?.name ?? 'Anak',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${state.ageInMonths} bulan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Questions
          ...state.questions.map((q) => _buildQuestionCard(q, state)),

          const SizedBox(height: 16),

          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jawaban Anda akan diproses menggunakan sistem pakar forward chaining untuk hasil yang akurat.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(FCQuestionModel question, FCKonsultasiState state) {
    final selectedAnswer = state.answers[question.key];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    question.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(question.category),
                  ),
                ),
              ),
              const Spacer(),
              if (selectedAnswer != null)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.map((option) {
            final isSelected = selectedAnswer == option;
            return GestureDetector(
              onTap: () {
                ref
                    .read(fcKonsultasiProvider.notifier)
                    .setAnswer(question.key, option);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryBlue.withValues(alpha: 0.1)
                      : const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.primaryBlue
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppConstants.primaryBlue
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppConstants.primaryBlue
                              : Colors.grey,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isSelected
                              ? AppConstants.primaryBlue
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'speech':
        return Colors.blue;
      case 'vocabulary':
        return Colors.purple;
      case 'articulation':
        return Colors.orange;
      case 'response':
        return Colors.green;
      case 'communication':
        return Colors.teal;
      case 'comprehension':
        return Colors.indigo;
      case 'social':
        return Colors.pink;
      case 'history':
        return Colors.brown;
      case 'medical':
        return Colors.red;
      case 'concern':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildResultStep(FCKonsultasiState state) {
    if (state.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state.result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() => _currentStep = 1);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final result = state.result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Header
          _buildResultHeader(result),

          const SizedBox(height: 24),

          // Risk Level Card
          _buildRiskLevelCard(result),

          const SizedBox(height: 24),

          // Summary Card
          _buildSummaryCard(result),

          const SizedBox(height: 24),

          // Recommendations Card
          _buildRecommendationsCard(result),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(result),
        ],
      ),
    );
  }

  Widget _buildResultHeader(DiagnosisModel result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(result.riskLevelColorValue),
            Color(result.riskLevelColorValue).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(_getRiskIcon(result.riskLevel), color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            result.riskLevelDisplay,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usia: ${result.ageInMonths} bulan (${result.ageCategory})',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Skor: ${result.score}%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MEDIUM':
        return Icons.info_rounded;
      case 'LOW':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Widget _buildRiskLevelCard(DiagnosisModel result) {
    final color = Color(result.riskLevelColorValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: color),
              const SizedBox(width: 8),
              Text(
                'Analisis Forward Chaining',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Fakta Ditemukan', '${result.derivedFacts.length}'),
          _buildInfoRow('Rules Dipicu', '${result.triggeredRules.length}'),
          _buildInfoRow('Confidence', '${(result.confidence * 100).toInt()}%'),
          _buildInfoRow('Kategori Temuan', '${result.findings.length}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DiagnosisModel result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: AppConstants.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Temuan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.findings.isEmpty)
            Text(
              'Tidak ada temuan khusus',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            )
          else
            ...result.findings.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(entry.key),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...entry.value.map(
                      (finding) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                finding,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(DiagnosisModel result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Rekomendasi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DiagnosisModel result) {
    return Column(
      children: [
        if (result.riskLevel != 'LOW')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/booking/therapist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: Text(
                'Booking Terapi Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // Restart consultation
            setState(() {
              _currentStep = 0;
              _selectedAnak = null;
            });
            ref.read(fcKonsultasiProvider.notifier).reset();
          },
          child: Text(
            'Konsultasi Ulang',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppConstants.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(FCKonsultasiState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Sebelumnya',
                onPressed: () {
                  setState(() => _currentStep--);
                },
                isOutlined: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: _currentStep == 0
                  ? (state.childId != null ? 'Lanjut' : 'Pilih Anak')
                  : _currentStep == 1
                  ? 'Analisis'
                  : 'Selesai',
              onPressed: _currentStep == 0
                  ? _handleNextFromStep0
                  : _currentStep == 1
                  ? _handleNextFromStep1
                  : () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextFromStep0() {
    if (_selectedAnak != null) {
      ref
          .read(fcKonsultasiProvider.notifier)
          .initializeWithChild(
            childId: _selectedAnak!.id,
            childName: _selectedAnak!.name,
            ageInMonths: _selectedAnak!.ageInMonths,
          );
      setState(() => _currentStep = 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih anak terlebih dahulu'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _handleNextFromStep1() async {
    final state = ref.read(fcKonsultasiProvider);
    final konsultasiNotifier = ref.read(fcKonsultasiProvider.notifier);

    if (state.answeredCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jawab minimal 1 pertanyaan'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Set loading state
    konsultasiNotifier.setLoading(true);

    try {
      // Send diagnosis request to backend API
      final apiService = ApiService();
      final response = await apiService.createDiagnosis(
        childId: state.childId!,
        answers: state.answers,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          final diagnosis = DiagnosisModel.fromJson(data['data']);
          konsultasiNotifier.setResult(diagnosis);
          setState(() => _currentStep = 2);
        } else {
          konsultasiNotifier.setError(
            data['message'] ?? 'Gagal memproses diagnosis',
          );
        }
      } else {
        konsultasiNotifier.setError('Gagal memproses diagnosis');
      }
    } catch (e) {
      debugPrint('Error creating diagnosis: $e');
      konsultasiNotifier.setError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
