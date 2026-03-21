import 'package:deteksi_telat_bicara/shared/widgets/parent_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart'; // Ensure bottom nav is correct

/// Therapist Patient Detail Page
/// Halaman detail pasien untuk terapis menggunakan view single-scroll
class TherapistPatientDetailPage extends ConsumerStatefulWidget {
  final String patientId;

  const TherapistPatientDetailPage({super.key, required this.patientId});

  @override
  ConsumerState<TherapistPatientDetailPage> createState() =>
      _TherapistPatientDetailPageState();
}

class _TherapistPatientDetailPageState
    extends ConsumerState<TherapistPatientDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final anak = anakState.anakList.firstWhere(
      (a) => a.id == widget.patientId,
      orElse: () => anakState.anakList.isNotEmpty
          ? anakState.anakList.first
          : throw Exception('Patient not found'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          anak.name,
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF64748B)),
            onPressed: () {
              // Action edit patient
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // White Container that fills the rest of the body
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(anak),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Ringkasan Kemajuan'),
                    const SizedBox(height: 16),
                    _buildProgressCards(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Riwayat Latihan'),
                        Text(
                          'Lihat Semua',
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseHistory(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Laporan & Dokumen'),
                    const SizedBox(height: 16),
                    _buildReports(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Catatan Sesi'),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppConstants.lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSessionNotes(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TherapistBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic anak) {
    return Column(
      children: [
        // Avatar with Badge
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/boy_avatar.png',
                    ), // Add proper asset or use icon
                    fit: BoxFit.cover,
                  ),
                ),
                child: anak.name.isNotEmpty
                    ? null
                    : const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32), // Green color for AKTIF
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AKTIF',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Name
        Center(
          child: Text(
            anak.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ID Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'ID: LK-2024-039',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Usia and Diagnosis
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'USIA',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _calculateAge(anak.birthDate),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'DIAGNOSIS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Delayed Speech -\nModerate',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFF1F5F9),
        ),
        const SizedBox(height: 16),
        // Last Session
        Center(
          child: Column(
            children: [
              Text(
                'SESI TERAKHIR',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '12 Okt 2023',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCards() {
    return Column(
      children: [
        _buildSingleProgressCard(
          icon: Icons.record_voice_over,
          color: AppConstants.primaryBlue,
          bgColor: const Color(0xFFF0F5FF),
          title: 'Kejelasan (Clarity)',
          increase: '+12% Bulan ini',
          value: 0.65,
        ),
        const SizedBox(height: 12),
        _buildSingleProgressCard(
          icon: Icons.menu_book,
          color: const Color(0xFF16A34A), // Green
          bgColor: const Color(0xFFF0FDF4),
          title: 'Kosakata (Vocabulary)',
          increase: '+5% Bulan ini',
          value: 0.40,
        ),
        const SizedBox(height: 12),
        _buildSingleProgressCard(
          icon: Icons.forum,
          color: const Color(0xFFD97706), // Gold/Brown
          bgColor: const Color(0xFFFFFBEB),
          title: 'Interaksi (Interaction)',
          increase: '+18% Bulan ini',
          value: 0.82,
        ),
      ],
    );
  }

  Widget _buildSingleProgressCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String increase,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Text(
                increase,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 36,
                child: Text(
                  '\${(value * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHistory() {
    return Column(
      children: [
        _buildExerciseItem(
          icon: Icons.mic,
          color: AppConstants.primaryBlue,
          bgColor: const Color(0xFFF0F5FF),
          title: 'Latihan Huruf S',
          subtitle: 'Kemarin • 15:30 • 0:45s',
        ),
        const SizedBox(height: 12),
        _buildExerciseItem(
          icon: Icons.extension,
          color: const Color(0xFF16A34A), // Green puzzle
          bgColor: const Color(0xFFF0FDF4),
          title: 'Tebak Hewan',
          subtitle: '14 Okt 2023 • 10:15 • 2:10s',
        ),
        const SizedBox(height: 12),
        _buildExerciseItem(
          icon: Icons.emoji_events,
          color: const Color(0xFFD97706), // Gold trophy
          bgColor: const Color(0xFFFFFBEB),
          title: 'Pengulangan Kata Kerja',
          subtitle: '12 Okt 2023 • 16:00 • 1:30s',
        ),
      ],
    );
  }

  Widget _buildExerciseItem({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppConstants.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildReports() {
    return Column(
      children: [
        _buildReportItem('Laporan Bulanan - Sept', 'PDF • 1.2 MB'),
        const SizedBox(height: 12),
        _buildReportItem('Hasil Observasi Awal', 'PDF • 2.6 MB'),
      ],
    );
  }

  Widget _buildReportItem(String title, String details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFFDC2626),
            size: 28,
          ), // Red PDF Icon
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: Color(0xFF64748B),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNotes() {
    return Column(
      children: [
        _buildTimelineItem(
          date: '12 OKT 2023',
          content:
              '"Budi mulai menunjukkan inisiatif untuk mengucapkan kata \'Minum\' tanpa dipicu. Kontak mata membaik secara signifikan."',
          author: 'Terapis: Dr. Sarah W.',
          isPrimary: true,
        ),
        _buildTimelineItem(
          date: '05 OKT 2023',
          content:
              '"Fokus pada artikulasi huruf \'S\' dan \'R\'. Budi masih kesulitan dengan posisi lidah, perlu alat bantu visual di sesi berikutnya."',
          author: 'Terapis: Dr. Sarah W.',
          isPrimary: false,
        ),
        _buildTimelineItem(
          date: '28 SEPT 2023',
          content:
              '"Sesi evaluasi bulanan. Ada progres pada pemahaman instruksi sederhana (2 tahap)."',
          author: 'Terapis: Dr. Sarah W.',
          isPrimary: false,
          isLast: true,
        ),
        const SizedBox(height: 24),
        // Text Input for New Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambah catatan baru...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // Action save note
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: Text(
              'Simpan Catatan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String content,
    required String author,
    required bool isPrimary,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPrimary
                      ? AppConstants.primaryBlue
                      : const Color(0xFFCBD5E1),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPrimary
                        ? AppConstants.primaryBlue.withValues(alpha: 0.3)
                        : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? AppConstants.primaryBlue
                          : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
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

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return '\$years Tahun \$months Bulan';
    } else {
      return '\$months Bulan';
    }
  }
}
