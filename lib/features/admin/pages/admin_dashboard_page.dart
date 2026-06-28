import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/providers/admin_notification_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/profile_avatar.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final statsResponse = await apiService.getAdminDashboard();

      if (statsResponse.statusCode == 200) {
        final data = statsResponse.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          setState(() {
            _stats = data['data'] ?? {};
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching admin dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(adminNotificationProvider);
    final recentNotifs = notifState.notifications.take(5).toList();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: LoadingWidget()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(notifState.summary),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 16),
              _buildSectionTitle('Aktivitas Terbaru'),
              const SizedBox(height: 12),
              recentNotifs.isEmpty
                  ? _buildEmptyActivity()
                  : _buildRecentNotifications(context, recentNotifs, notifState.summary.totalUnread),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(AdminNotificationSummary summary) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beranda Admin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            'Kelola aplikasi Terapi Wicara',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF111827)),
              onPressed: () => context.push('/admin/notifikasi'),
            ),
            if (summary.totalUnread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${summary.totalUnread > 99 ? '99+' : summary.totalUnread}',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }



  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryBlue, AppConstants.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            name: 'Admin',
            radius: 24,
            borderWidth: 2,
            borderColor: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, Admin!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola semua data aplikasi dari sini',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ringkasan'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Orang Tua',
              '${_stats['parentCount'] ?? 0}',
              Icons.people,
              const Color(0xFF3B82F6),
              const Color(0xFF3B82F6).withValues(alpha: 0.1),
              () => context.go('/admin/users'),
            ),
            _buildStatCard(
              'Terapis',
              '${_stats['therapistCount'] ?? 0}',
              Icons.medical_services,
              const Color(0xFF10B981),
              const Color(0xFF10B981).withValues(alpha: 0.1),
              () => context.go('/admin/users'),
            ),
            _buildStatCard(
              'Sesi Selesai',
              '${_stats['sessionCount'] ?? 0}',
              Icons.calendar_today,
              const Color(0xFFF59E0B),
              const Color(0xFFF59E0B).withValues(alpha: 0.1),
              () {},
            ),
            _buildStatCard(
              'Anak',
              '${_stats['childrenCount'] ?? 0}',
              Icons.child_care,
              const Color(0xFF8B5CF6),
              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              () {},
            ),
            _buildStatCard(
              'Aset Server',
              'Manajemen',
              Icons.folder_shared,
              const Color(0xFFEC4899),
              const Color(0xFFEC4899).withValues(alpha: 0.1),
              () => context.push('/admin/assets'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    Text(
                      _stats['revenueFormatted'] ?? 'Rp 0',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                ),
                Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'Belum ada aktivitas terbaru',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotifications(
    BuildContext context,
    List<NotificationModel> notifications,
    int totalUnread,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          ...notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final n = entry.value;
            final isLast = index == notifications.length - 1;
            return _buildNotificationTile(n, isLast);
          }),
          if (totalUnread > 5)
            Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => context.push('/admin/notifikasi'),
                child: Text(
                  'Lihat semua notifikasi ($totalUnread belum dibaca)',
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel n, bool isLast) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _getIconColor(n.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(n.type), size: 20, color: _getIconColor(n.type)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  n.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827),
                  ),
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppConstants.primaryBlue, shape: BoxShape.circle),
                ),
            ],
          ),
          subtitle: Text(
            n.body,
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN_THERAPIST_REGISTRATION':
        return Icons.person_add_alt_1_rounded;
      case 'ADMIN_PAYMENT_SUCCESS':
        return Icons.check_circle_rounded;
      case 'ADMIN_PAYMENT_FAILED':
        return Icons.cancel_rounded;
      case 'ADMIN_NEW_REPORT':
        return Icons.description_rounded;
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        return Icons.warning_amber_rounded;
      case 'ADMIN_NEW_BOOKING':
        return Icons.calendar_month_rounded;
      case 'ADMIN_SESSION_COMPLETED':
        return Icons.task_alt_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN_THERAPIST_REGISTRATION':
        return const Color(0xFF10B981);
      case 'ADMIN_PAYMENT_SUCCESS':
        return const Color(0xFF10B981);
      case 'ADMIN_PAYMENT_FAILED':
        return const Color(0xFFEF4444);
      case 'ADMIN_NEW_REPORT':
        return const Color(0xFFF59E0B);
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        return const Color(0xFFEF4444);
      case 'ADMIN_NEW_BOOKING':
        return const Color(0xFF3B82F6);
      case 'ADMIN_SESSION_COMPLETED':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
