import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../providers/laporan_provider.dart';
import '../../../core/models/laporan_model.dart';

class TherapistReportDetailPage extends ConsumerStatefulWidget {
  final String laporanId;

  const TherapistReportDetailPage({super.key, required this.laporanId});

  @override
  ConsumerState<TherapistReportDetailPage> createState() =>
      _TherapistReportDetailPageState();
}

class _TherapistReportDetailPageState
    extends ConsumerState<TherapistReportDetailPage> {
  LaporanModel? _selectedLaporan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(laporanProvider.notifier).fetchLaporan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final laporanState = ref.watch(laporanProvider);

    try {
      _selectedLaporan = laporanState.laporanList.firstWhere(
        (l) => l.id == widget.laporanId,
      );
    } catch (_) {
      _selectedLaporan = null;
    }

    if (laporanState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedLaporan == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: const CustomAppBar(
          title: 'Laporan Tidak Ditemukan',
          showBackButton: true,
          showLogo: false,
        ),
        body: Center(
          child: Text(
            'Laporan tidak ditemukan. Silakan kembali.',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    final laporan = _selectedLaporan!;
    final isDraft = laporan.status == 'DRAFT';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(
        title: 'Detail Laporan',
        showBackButton: true,
        showLogo: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(laporan, isDraft),
            const SizedBox(height: 24),
            _buildReportContent(laporan),
            const SizedBox(height: 40),
            if (isDraft) _buildDraftActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(LaporanModel laporan, bool isDraft) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(
                  laporan.patientAvatar.isNotEmpty
                      ? laporan.patientAvatar
                      : 'assets/images/boy_avatar.png',
                ),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laporan.patientName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'ID: ${laporan.patientId}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDraft
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFA7F3D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  laporan.status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDraft
                        ? const Color(0xFF92400E)
                        : const Color(0xFF064E3B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey.withValues(alpha: 0.2),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dibuat: ${laporan.date}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(LaporanModel laporan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_ind,
                  color: AppConstants.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rangkuman Sesi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            laporan.summary,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Laporan berhasil dikirim!')),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Emerald green
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Kirim Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              // Edit Action placeholder
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppConstants.primaryBlue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.edit,
                  color: AppConstants.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit Ulang',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
