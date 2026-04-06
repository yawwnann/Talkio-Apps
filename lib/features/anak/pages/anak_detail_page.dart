import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// Halaman Detail Anak dengan Tabs (Data, Progress, Riwayat)
class AnakDetailPage extends ConsumerStatefulWidget {
  final String anakId;

  const AnakDetailPage({super.key, required this.anakId});

  @override
  ConsumerState<AnakDetailPage> createState() => _AnakDetailPageState();
}

class _AnakDetailPageState extends ConsumerState<AnakDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AnakModel? _anak;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnakData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAnakData() {
    final anakState = ref.read(anakProvider);
    _anak = anakState.selectedAnak;

    if (_anak == null || _anak!.id != widget.anakId) {
      try {
        _anak = anakState.anakList.firstWhere((a) => a.id == widget.anakId);
      } catch (e) {
        _anak = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);

    // Re-load data when watching provider
    if (_anak == null && anakState.anakList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAnakData();
        if (mounted) setState(() {});
      });
    }

    if (_anak == null) {
      return Scaffold(
        appBar: const SimpleAppBar(title: 'Detail Anak'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.child_care_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Data anak tidak ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: CustomAppBar(
        title: 'Detail Anak',
        showBackButton: true,
        showUserMenu: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/anak/edit/${_anak!.id}'),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(_anak!),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppConstants.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppConstants.primaryBlue,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.person_outline), text: 'Data'),
                Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
                Tab(icon: Icon(Icons.history), text: 'Riwayat'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDataTab(_anak!),
                _buildProgressTab(_anak!),
                _buildRiwayatTab(_anak!),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildQuickActions(_anak!),
    );
  }

  Widget _buildProfileHeader(AnakModel anak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryBlue, AppConstants.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                anak.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            anak.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderBadge(
                icon: Icons.cake_outlined,
                label: '${anak.age} Th',
              ),
              const SizedBox(width: 12),
              _buildHeaderBadge(
                icon: anak.gender == 'L' ? Icons.male : Icons.female,
                label: anak.gender == 'L' ? 'Laki-laki' : 'Perempuan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab(AnakModel anak) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informasi Pribadi Card
          _buildInfoCard(
            title: 'Informasi Pribadi',
            icon: Icons.person_outline,
            iconColor: AppConstants.primaryBlue,
            children: [
              _buildDataRow('Tanggal Lahir', _formatDate(anak.dateOfBirth)),
              _buildDataRow('Usia', '${anak.age} tahun (${anak.ageInMonths} bulan)'),
              _buildDataRow('Jenis Kelamin', anak.gender == 'MALE' ? 'Laki-laki' : 'Perempuan'),
            ],
          ),

          const SizedBox(height: 16),

          // Informasi Akun Card
          _buildInfoCard(
            title: 'Informasi Akun',
            icon: Icons.info_outline,
            iconColor: AppConstants.infoCyan,
            children: [
              _buildDataRow('Terdaftar Sejak', _formatDate(anak.createdAt)),
              _buildDataRow('Terakhir Diupdate', _formatDate(anak.updatedAt)),
            ],
          ),

          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildProgressTab(AnakModel anak) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryBlue.withValues(alpha: 0.1),
                  AppConstants.lightBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: AppConstants.primaryBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  'Progress Terapi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitoring perkembangan anak',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Metrics
          _buildProgressCard(
            title: 'Komunikasi',
            progress: 0.65,
            color: const Color(0xFF8B7355),
            icon: Icons.chat_outlined,
          ),

          const SizedBox(height: 12),

          _buildProgressCard(
            title: 'Motorik Halus',
            progress: 0.72,
            color: const Color(0xFF6B9B6E),
            icon: Icons.touch_app_outlined,
          ),

          const SizedBox(height: 12),

          _buildProgressCard(
            title: 'Sosialisasi',
            progress: 0.58,
            color: const Color(0xFF5A8F5A),
            icon: Icons.people_outline,
          ),

          const SizedBox(height: 12),

          _buildProgressCard(
            title: 'Kognitif',
            progress: 0.70,
            color: const Color(0xFF6B8F9B),
            icon: Icons.psychology_outlined,
          ),

          const SizedBox(height: 24),

          // Achievements
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppConstants.warningOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Pencapaian',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  '🎯 10 Sesi Terapi',
                  'Selesai 3 hari yang lalu',
                  true,
                ),
                const SizedBox(height: 8),
                _buildAchievementItem(
                  '🎤 Suara Jelas',
                  'Selesai 1 minggu yang lalu',
                  true,
                ),
                const SizedBox(height: 8),
                _buildAchievementItem(
                  '⭐ 100 Poin Game',
                  'Dalam progres',
                  false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
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
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, String subtitle, bool completed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed
            ? AppConstants.successColor.withValues(alpha: 0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.pending,
            color: completed ? AppConstants.successColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab(AnakModel anak) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Riwayat Konsultasi
          _buildRiwayatSection(
            title: 'Riwayat Konsultasi',
            icon: Icons.chat_outlined,
            iconColor: AppConstants.primaryBlue,
            items: [
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 7)),
                title: 'Konsultasi Awal',
                subtitle: 'Evaluasi perkembangan bicara',
                status: 'completed',
              ),
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 30)),
                title: 'Follow-up',
                subtitle: 'Monitoring progress terapi',
                status: 'completed',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Riwayat Terapi
          _buildRiwayatSection(
            title: 'Riwayat Terapi',
            icon: Icons.medical_services_outlined,
            iconColor: AppConstants.successColor,
            items: [
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 3)),
                title: 'Terapi Wicara - Sesi 5',
                subtitle: 'Latihan pengucapan kata',
                status: 'completed',
              ),
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 10)),
                title: 'Terapi Wicara - Sesi 4',
                subtitle: 'Latihan artikulasi',
                status: 'completed',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Riwayat Game
          _buildRiwayatSection(
            title: 'Aktivitas Game',
            icon: Icons.games_outlined,
            iconColor: AppConstants.warningOrange,
            items: [
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 1)),
                title: 'Latihan Suara',
                subtitle: 'Skor: 85/100',
                status: 'completed',
              ),
              _buildRiwayatItem(
                date: DateTime.now().subtract(const Duration(days: 2)),
                title: 'Tebak Gambar',
                subtitle: 'Skor: 92/100',
                status: 'completed',
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRiwayatSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildRiwayatItem({
    required DateTime date,
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: status == 'completed'
                  ? AppConstants.successColor.withValues(alpha: 0.1)
                  : AppConstants.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == 'completed' ? Icons.check : Icons.schedule,
              color: status == 'completed'
                  ? AppConstants.successColor
                  : AppConstants.warningOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRelativeDate(date),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AnakModel anak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Mulai Terapi',
                color: AppConstants.successColor,
                onTap: () => context.push('/game'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                color: AppConstants.warningOrange,
                onTap: () => context.push('/jadwal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.analytics_outlined,
                label: 'Laporan',
                color: AppConstants.primaryBlue,
                onTap: () => context.push('/laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: isHighlight
                  ? const EdgeInsets.all(12)
                  : EdgeInsets.zero,
              decoration: isHighlight
                  ? BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    )
                  : null,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tidak tersedia';
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} minggu lalu';
    } else if (diff.inDays < 365) {
      return '${diff.inDays ~/ 30} bulan lalu';
    } else {
      return '${diff.inDays ~/ 365} tahun lalu';
    }
  }
}
