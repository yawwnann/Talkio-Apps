import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../providers/laporan_provider.dart';

class TherapistReportListPage extends ConsumerStatefulWidget {
  const TherapistReportListPage({super.key});

  @override
  ConsumerState<TherapistReportListPage> createState() =>
      _TherapistReportListPageState();
}

class _TherapistReportListPageState
    extends ConsumerState<TherapistReportListPage> {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(
        title: 'Laporan',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildOverviewCards(laporanState),
            const SizedBox(height: 32),
            _buildReportListHeader(),
            const SizedBox(height: 16),
            _buildReportList(laporanState),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/therapist/laporan/add');
        },
        backgroundColor: AppConstants.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: TherapistBottomNav(currentIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Cari laporan atau nama pasien...',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(LaporanState state) {
    final draftCount = state.laporanList
        .where((l) => l.status == 'DRAFT')
        .length;
    final sentCount = state.laporanList.where((l) => l.status == 'SENT').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6DA5FF), // Blue matching mockup
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.article,
                      size: 60,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$draftCount',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Laporan Draft',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFA7F3D0), // Light Green matching mockup
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$sentCount',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF064E3B),
                        ),
                      ),
                      Text(
                        'Laporan\nTerkirim',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF064E3B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Laporan Terbaru',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(LaporanState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.laporanList.isEmpty) {
      return Center(
        child: Text(
          'Belum ada laporan.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: state.laporanList.map((laporan) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                context.push('/therapist/laporan/${laporan.id}');
              },
              child: _buildReportCard(
                name: laporan.patientName,
                id: laporan.patientId,
                status: laporan.status,
                summary: laporan.summary,
                date: laporan.date,
                avatarAsset: laporan.patientAvatar,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportCard({
    required String name,
    required String id,
    required String status,
    required String summary,
    required String date,
    required String avatarAsset,
  }) {
    final isDraft = status == "DRAFT";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(avatarAsset),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'ID: $id',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDraft
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFA7F3D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
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
          // Summary text
          Text(
            summary,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Divider
          Divider(
            color: Colors.grey.withValues(alpha: 0.2),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppConstants.primaryBlue,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
