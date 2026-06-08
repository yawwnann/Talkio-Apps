import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import '../../jadwal/providers/parent_schedule_provider.dart';

/// Parent Dashboard Page
/// Halaman dashboard modern untuk orang tua dengan desain mirip therapist dashboard
class ParentDashboardPage extends ConsumerStatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() =>
      _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(anakProvider.notifier).getAnakList(user.id);
        ref.read(parentScheduleProvider.notifier).fetchSchedule();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(
        title: 'Terapi Wicara',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await Future.wait([
              ref.read(anakProvider.notifier).getAnakList(user.id),
              ref.read(parentScheduleProvider.notifier).fetchSchedule(),
            ]);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(user?.name ?? 'Orang Tua'),
              const SizedBox(height: 20),
              _buildChildDevelopment(),
              const SizedBox(height: 20),
              _buildNearestTherapy(),
              const SizedBox(height: 20),
              _buildQuickAccess(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF005BAC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo,  $name !',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Mari temani tumbuh kembang si kecil\ndengan penuh kasih hari ini.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildDevelopment() {
    final anakList = ref.watch(anakProvider.select((state) => state.anakList));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data Anak',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
              if (anakList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${anakList.length} Anak',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (ref.watch(anakProvider).isLoading && anakList.isEmpty)
            ...List.generate(2, (index) => _buildChildSkeleton())
          else if (anakList.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada data anak',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...anakList.map((anak) => _buildChildCard(anak)),
        ],
      ),
    );
  }

  Widget _buildChildCard(AnakModel anak) {
    final age = _calculateAge(anak.dateOfBirth);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                anak.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: anak.gender == 'L'
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  anak.gender == 'L' ? 'Laki-laki' : 'Perempuan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: anak.gender == 'L'
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFC2185B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatDate(anak.dateOfBirth),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.cake, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '$age tahun',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          // medicalHistory field removed - backend doesn't support it
        ],
      ),
    );
  }

  Widget _buildChildSkeleton() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 120, height: 20, color: Colors.white),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 14, height: 14, color: Colors.white),
                const SizedBox(width: 6),
                Container(width: 80, height: 16, color: Colors.white),
                const SizedBox(width: 16),
                Container(width: 14, height: 14, color: Colors.white),
                const SizedBox(width: 6),
                Container(width: 60, height: 16, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildProgressItem(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildNearestTherapy() {
    final scheduleState = ref.watch(parentScheduleProvider);

    // Find nearest active schedule
    final now = DateTime.now();
    final activeSchedules = scheduleState.scheduleList.where((s) {
      if (s['isActive'] != true) return false;
      try {
        final date = DateTime.parse(s['schedule']);
        return date.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();

    // Sort ascending
    activeSchedules.sort(
      (a, b) => DateTime.parse(
        a['schedule'],
      ).compareTo(DateTime.parse(b['schedule'])),
    );

    final nearestSchedule = activeSchedules.isNotEmpty
        ? activeSchedules.first
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal Telah di Booking',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (scheduleState.isLoading && activeSchedules.isEmpty)
            _buildScheduleSkeleton()
          else if (nearestSchedule == null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada jadwal booking',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8860B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateTime.parse(nearestSchedule['schedule']).toLocal().day}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nearestSchedule['therapyType'] ?? 'Terapi Bicara',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pukul ${DateFormat('HH.mm').format(DateTime.parse(nearestSchedule['schedule']).toLocal())} WIB',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Terapis: ${nearestSchedule['therapistName'] ?? 'Belum ditugaskan'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.child_care,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Anak: ${nearestSchedule['childName'] ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/jadwal');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lihat Jadwal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSkeleton() {
    return ShimmerLoading(
      isLoading: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 18, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 16, height: 16, color: Colors.white),
              const SizedBox(width: 6),
              Container(width: 140, height: 14, color: Colors.white),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 16, height: 16, color: Colors.white),
              const SizedBox(width: 6),
              Container(width: 100, height: 14, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akses Cepat',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAccessItem(
            Icons.psychology_outlined,
            'Deteksi Speech Delay',
            'Cek perkembangan bicara anak',
            const Color(0xFFE3F2FD),
            const Color(0xFF2196F3),
            () => context.push('/konsultasi'),
          ),
          const SizedBox(height: 12),
          _buildQuickAccessItem(
            Icons.assignment_outlined,
            'Riwayat Deteksi',
            'Lihat hasil deteksi sebelumnya',
            const Color(0xFFE8F5E9),
            const Color(0xFF4CAF50),
            () => context.push('/diagnosa'),
          ),
          const SizedBox(height: 12),
          _buildQuickAccessItem(
            Icons.calendar_today_outlined,
            'Booking Terapi',
            'Pilih therapist & jadwal',
            const Color(0xFFE3F2FD),
            const Color(0xFF2196F3),
            () => context.push('/booking/therapist'),
          ),
          const SizedBox(height: 12),
          _buildQuickAccessItem(
            Icons.upload_file_outlined,
            'Unggah Progress',
            'Bagikan media dengan terapis',
            const Color(0xFFF3E5F5),
            const Color(0xFF9C27B0),
            () => context.push('/progress/upload'),
          ),
          const SizedBox(height: 12),
          _buildQuickAccessItem(
            Icons.description_outlined,
            'Lihat Laporan',
            'Laporan perkembangan anak',
            const Color(0xFFFCE4EC),
            const Color(0xFFDC2626),
            () => context.push('/laporan'),
          ),
          const SizedBox(height: 12),
          _buildQuickAccessItem(
            Icons.games_outlined,
            'Game',
            'Aktivitas interaktif hari ini',
            const Color(0xFFFFF9E6),
            const Color(0xFFB8860B),
            () => context.push('/game'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
