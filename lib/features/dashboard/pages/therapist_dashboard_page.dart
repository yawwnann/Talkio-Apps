import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';

class TherapistDashboardPage extends ConsumerStatefulWidget {
  const TherapistDashboardPage({super.key});

  @override
  ConsumerState<TherapistDashboardPage> createState() =>
      _TherapistDashboardPageState();
}

class _TherapistDashboardPageState extends ConsumerState<TherapistDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStatsProvider.notifier).fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final dashboardState = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(
        title: 'Talkio',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.stats == null
              ? _buildErrorState(dashboardState.error)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(user?.name ?? 'Terapis', dashboardState.stats),
                      const SizedBox(height: 20),
                      _buildNewUpdatesCard(dashboardState.stats),
                      const SizedBox(height: 20),
                      _buildTodayScheduleSection(context, dashboardState.stats),
                      const SizedBox(height: 20),
                      _buildImprovementTrends(dashboardState.stats),
                      const SizedBox(height: 20),
                      _buildActivePatientsSection(context, dashboardState.stats),
                    ],
                  ),
                ),
      bottomNavigationBar: TherapistBottomNav(currentIndex: 0),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            error ?? 'Terjadi kesalahan',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(dashboardStatsProvider.notifier).fetchDashboardStats();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String name, Map<String, dynamic>? stats) {
    final summary = stats?['summary'] ?? {};
    final newRecordings = summary['newRecordings'] ?? 0;
    final pendingReports = summary['pendingReports'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryBlue, AppConstants.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang Kembali,',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Anda memiliki $newRecordings rekaman suara baru dan $pendingReports\nlaporan perkembangan pasien yang menunggu\nuntuk ditinjau hari ini.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to reports page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstants.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tinjau\nLaporan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to schedule page
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lihat\nJadwal',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewUpdatesCard(Map<String, dynamic>? stats) {
    final recentUpdates = stats?['recentUpdates'] as List<dynamic>? ?? [];
    final updateCount = recentUpdates.isNotEmpty ? recentUpdates.length : 0;

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
                'Pembaruan Terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (updateCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B7A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$updateCount BARU',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentUpdates.isEmpty)
            Center(
              child: Text(
                'Belum ada pembaruan terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            )
          else
            ...recentUpdates.take(6).map((update) {
              final type = update['type'] ?? 'SESSION';
              final isReport = type == 'REPORT';
              final isSession = type == 'SESSION';
              
              IconData icon;
              String title;
              Color iconColor;
              
              if (isReport) {
                icon = Icons.description;
                title = 'Laporan: ${update['childName'] ?? 'Pasien'}';
                iconColor = const Color(0xFF4CAF50); // Green
              } else if (isSession) {
                final therapyType = update['therapyType'] ?? '';
                if (therapyType.toUpperCase() == 'RECORDING') {
                  icon = Icons.mic;
                  title = 'Rekaman Suara: ${update['childName'] ?? 'Pasien'}';
                  iconColor = const Color(0xFF4A90E2); // Blue
                } else {
                  icon = Icons.calendar_today;
                  title = 'Sesi: ${update['childName'] ?? 'Pasien'}';
                  iconColor = const Color(0xFFFF9800); // Orange
                }
              } else {
                icon = Icons.info;
                title = update['title'] ?? update['childName'] ?? 'Update';
                iconColor = const Color(0xFF9E9E9E); // Grey
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUpdateItemNew(
                  icon,
                  title,
                  _formatTimeAgo(update['createdAt']),
                  iconColor,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Baru saja';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else {
        return '${difference.inDays} hari lalu';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  Widget _buildUpdateItemNew(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context, Map<String, dynamic>? stats) {
    final todaySchedule = stats?['todaySchedule'] ?? {};
    final sessions = todaySchedule['sessions'] as List<dynamic>? ?? [];
    final sessionCount = todaySchedule['count'] ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Jadwal Terapi Hari Ini',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to calendar view
              },
              child: Text(
                'Lihat Kalender >',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Tidak ada jadwal hari ini',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          ...sessions.map((session) {
            final time = _formatSessionTime(session['time']);
            final color = _getStatusColor(session['status']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to session detail
                },
                child: _buildScheduleItem(
                  time,
                  session['childName'] ?? 'Pasien',
                  session['therapyType'] ?? 'Terapi Bicara',
                  color,
                ),
              ),
            );
          }).toList(),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              // TODO: Open create schedule dialog
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              'Buat Sesi Baru',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatSessionTime(String? timeStr) {
    if (timeStr == null) return '00:00';
    try {
      final dateTime = DateTime.parse(timeStr);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return timeStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'ONGOING':
        return AppConstants.primaryBlue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildScheduleItem(
    String time,
    String name,
    String type,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildImprovementTrends(Map<String, dynamic>? stats) {
    final trends = stats?['trends'] ?? {};
    final averageImprovement = trends['averageImprovement'] ?? '0%';
    final vocabularyScore = trends['vocabularyScore'] ?? '0%';
    final dailyEngagement = trends['dailyEngagement'] ?? '0%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Tren Peningkatan Pasien',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTrendItem(
            'Rata-rata Grafik Keberhasilan',
            averageImprovement,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
            'Kartu Skor Kosakata',
            vocabularyScore,
            AppConstants.primaryBlue,
          ),
          const SizedBox(height: 16),
          _buildTrendItem('Keterlibatan Harian', dailyEngagement, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              percentage,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.trending_up, color: color, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.7,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildActivePatientsSection(BuildContext context, Map<String, dynamic>? stats) {
    final activePatients = stats?['activePatients'] ?? {};
    final patients = activePatients['patients'] as List<dynamic>? ?? [];
    final patientCount = activePatients['count'] ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Pasien Aktif',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (patientCount > 0)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all patients page
                },
                child: Text(
                  'Semua ($patientCount)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (patients.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Belum ada pasien aktif',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          ...patients.take(5).map((patient) {
            final lastSessionText = _formatLastSessionTime(patient['lastSession']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to patient detail
                  // context.push('/therapist/patients/${patient['id']}');
                },
                child: _buildPatientItem(
                  patient['name'] ?? 'Pasien',
                  lastSessionText,
                ),
              ),
            );
          }).toList(),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to manage all patients
            },
            child: Text(
              'Kelola Semua Pasien',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatLastSessionTime(String? lastSessionStr) {
    if (lastSessionStr == null) return 'Belum ada sesi';
    try {
      final date = DateTime.parse(lastSessionStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Sesi terakhir hari ini';
      } else if (difference.inDays == 1) {
        return 'Sesi terakhir kemarin';
      } else if (difference.inDays < 7) {
        return 'Sesi terakhir ${difference.inDays} hari yang lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Sesi terakhir $weeks minggu yang lalu';
      } else {
        final months = (difference.inDays / 30).floor();
        return 'Sesi terakhir $months bulan yang lalu';
      }
    } catch (e) {
      return 'Sesi terakhir tidak diketahui';
    }
  }

  Widget _buildPatientItem(String name, String lastSession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(
            name: name,
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  lastSession,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
