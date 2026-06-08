import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import 'package:intl/intl.dart';

class TherapistDashboardPage extends ConsumerStatefulWidget {
  const TherapistDashboardPage({super.key});

  @override
  ConsumerState<TherapistDashboardPage> createState() =>
      _TherapistDashboardPageState();
}

class _TherapistDashboardPageState
    extends ConsumerState<TherapistDashboardPage> {
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Terapi Wicara',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
        showUserMenu: false,
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null && dashboardState.stats == null
          ? _buildErrorState(dashboardState.error)
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(dashboardStatsProvider.notifier)
                  .fetchDashboardStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(user?.name ?? 'Terapis'),
                    const SizedBox(height: 20),
                    _buildSummaryStats(dashboardState.stats),
                    const SizedBox(height: 20),
                    _buildTodaySchedule(dashboardState.stats),
                    const SizedBox(height: 20),
                    _buildRecentBookings(dashboardState.stats),
                    const SizedBox(height: 20),
                    _buildActivePatients(dashboardState.stats),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const TherapistBottomNav(currentIndex: 0),
    );
  }

  /// Header dengan sapaan
  Widget _buildHeader(String name) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  String _getGreeting(DateTime time) {
    if (time.hour < 10) return 'Selamat Pagi 👋';
    if (time.hour < 15) return 'Selamat Siang 👋';
    if (time.hour < 18) return 'Selamat Sore 👋';
    return 'Selamat Malam 👋';
  }

  /// Summary stats (3 kartu statistik)
  Widget _buildSummaryStats(Map<String, dynamic>? stats) {
    final todayCount = stats?['todaySchedule']?['count'] ?? 0;
    final activeCount = stats?['activePatients']?['count'] ?? 0;
    final pendingCount = stats?['summary']?['pendingReports'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: 'Sesi Hari Ini',
            value: todayCount.toString(),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'Pasien Aktif',
            value: activeCount.toString(),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: 'Menunggu',
            value: pendingCount.toString(),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Jadwal terapi hari ini
  Widget _buildTodaySchedule(Map<String, dynamic>? stats) {
    final sessions = stats?['todaySchedule']?['sessions'] as List? ?? [];
    final sessionCount = stats?['todaySchedule']?['count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Jadwal Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            if (sessionCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sessionCount sesi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          _buildEmptyCard(
            icon: Icons.event_available_rounded,
            title: 'Tidak ada jadwal',
            subtitle: 'Tidak ada sesi terapi scheduled untuk hari ini',
            iconColor: const Color(0xFF94A3B8),
          )
        else
          ...sessions.map(
            (session) => _buildScheduleItem(
              context,
              session['childId']?.toString() ?? '',
              session['childName']?.toString() ?? 'Pasien',
              session['time']?.toString() ?? '',
              session['therapyType']?.toString() ?? 'Terapi Wicara',
              session['status']?.toString() ?? 'SCHEDULED',
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    String childId,
    String childName,
    String timeStr,
    String therapyType,
    String status,
  ) {
    final time = _formatTime(timeStr);
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push('/therapist/pasien/$childId'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      therapyType,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      // Parse as local time (backend stores in local time)
      final dateTime = DateTime.parse(timeStr);
      return DateFormat('HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return timeStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'ONGOING':
        return const Color(0xFF3B82F6);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      case 'PENDING_CONFIRMATION':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Selesai';
      case 'ONGOING':
        return 'Berlangsung';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'PENDING_CONFIRMATION':
        return 'Menunggu';
      case 'SCHEDULED':
        return 'Dijadwalkan';
      default:
        return status;
    }
  }

  /// Aktivitas booking terbaru
  Widget _buildRecentBookings(Map<String, dynamic>? stats) {
    final updates = stats?['recentUpdates'] as List? ?? [];
    final updateCount = updates.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktivitas Terbaru',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            if (updateCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$updateCount baru',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (updates.isEmpty)
          _buildEmptyCard(
            icon: Icons.inbox_rounded,
            title: 'Belum ada aktivitas',
            subtitle: 'Aktivitas booking akan muncul di sini',
            iconColor: const Color(0xFF94A3B8),
          )
        else
          ...updates
              .take(5)
              .map(
                (update) => _buildBookingItem(
                  context,
                  update['childId']?.toString(),
                  update['childName']?.toString() ?? 'Pasien',
                  update['type']?.toString() ?? 'SESSION',
                  update['createdAt']?.toString(),
                  update['therapyType']?.toString(),
                ),
              ),
      ],
    );
  }

  Widget _buildBookingItem(
    BuildContext context,
    String? childId,
    String childName,
    String type,
    String? createdAt,
    String? therapyType,
  ) {
    IconData icon;
    Color iconColor;
    String typeLabel;

    if (type.toUpperCase() == 'REPORT') {
      icon = Icons.description_rounded;
      iconColor = const Color(0xFF10B981);
      typeLabel = 'Laporan';
    } else if (therapyType?.toUpperCase() == 'RECORDING') {
      icon = Icons.mic_rounded;
      iconColor = const Color(0xFF3B82F6);
      typeLabel = 'Rekaman';
    } else {
      icon = Icons.event_rounded;
      iconColor = const Color(0xFFF59E0B);
      typeLabel = 'Booking';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: childId != null
            ? () => context.push('/therapist/pasien/$childId')
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimeAgo(createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Baru saja';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit';
      if (diff.inHours < 24) return '${diff.inHours} jam';
      return '${diff.inDays} hari';
    } catch (e) {
      return 'Baru saja';
    }
  }

  /// Pasien aktif
  Widget _buildActivePatients(Map<String, dynamic>? stats) {
    final patients = stats?['activePatients']?['patients'] as List? ?? [];
    final patientCount = stats?['activePatients']?['count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.people_rounded,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pasien Aktif',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            if (patientCount > 0)
              TextButton(
                onPressed: () => context.push('/therapist/pasien'),
                child: Text(
                  'Lihat semua ($patientCount)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (patients.isEmpty)
          _buildEmptyCard(
            icon: Icons.person_off_rounded,
            title: 'Belum ada pasien',
            subtitle: 'Pasien akan muncul setelah ada booking',
            iconColor: const Color(0xFF94A3B8),
          )
        else
          ...patients
              .take(5)
              .map(
                (patient) => _buildPatientItem(
                  context,
                  patient['id']?.toString() ?? '',
                  patient['name']?.toString() ?? 'Pasien',
                  patient['lastSession']?.toString(),
                ),
              ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.folder_rounded,
          label: 'Kelola Pasien',
          onTap: () => context.push('/therapist/pasien'),
        ),
      ],
    );
  }

  Widget _buildPatientItem(
    BuildContext context,
    String patientId,
    String patientName,
    String? lastSession,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push('/therapist/pasien/$patientId'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ProfileAvatar(name: patientName, radius: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastSession != null
                          ? _formatLastSession(lastSession)
                          : 'Belum ada sesi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastSession(String? lastSessionStr) {
    if (lastSessionStr == null) return 'Belum ada sesi';
    try {
      final date = DateTime.parse(lastSessionStr);
      final diff = DateTime.now().difference(date);

      if (diff.inDays == 0) return 'Sesi hari ini';
      if (diff.inDays == 1) return 'Sesi kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
      return '${(diff.inDays / 30).floor()} bulan lalu';
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  /// Empty state card
  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
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
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state
  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Terjadi kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(dashboardStatsProvider.notifier)
                  .fetchDashboardStats(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
