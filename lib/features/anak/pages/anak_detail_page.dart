import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/models/diagnosis_model.dart';
import '../../../core/models/game_log_model.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../diagnosa/providers/diagnosis_provider.dart';

/// Halaman Detail Anak dengan Tabs (Data, Riwayat)
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
  final ApiService _apiService = ApiService();
  List<dynamic> _therapySessions = [];
  List<GameLogModel> _gameLogs = [];
  bool _isLoadingRiwayat = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        _fetchRiwayatData();
      } catch (e) {
        _anak = null;
      }
    }
  }

  Future<void> _fetchRiwayatData() async {
    if (_anak == null) return;
    setState(() => _isLoadingRiwayat = true);
    try {
      final historyRes = await _apiService.getTherapyHistory();
      if (historyRes.statusCode == 200 &&
          historyRes.data is Map &&
          historyRes.data['status'] == 'success') {
        final sessions = historyRes.data['data'] as List? ?? [];
        _therapySessions = sessions
            .where(
              (s) =>
                  s['childId'] == _anak!.id ||
                  (s['child'] is Map && s['child']['id'] == _anak!.id),
            )
            .toList();
      }

      final gameRes = await _apiService.getGameHistory(_anak!.id);
      if (gameRes.statusCode == 200 &&
          gameRes.data is Map &&
          gameRes.data['status'] == 'success') {
        final rawLogs = gameRes.data['data'] as List? ?? [];
        _gameLogs = rawLogs
            .map((e) => GameLogModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      // silently fail - show empty state
    }
    if (mounted) setState(() => _isLoadingRiwayat = false);
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
                Tab(icon: Icon(Icons.history), text: 'Riwayat'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDataTab(_anak!), _buildRiwayatTab(_anak!)],
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
              _buildDataRow(
                'Usia',
                '${anak.age} tahun (${anak.ageInMonths} bulan)',
              ),
              _buildDataRow(
                'Jenis Kelamin',
                anak.gender == 'MALE' ? 'Laki-laki' : 'Perempuan',
              ),
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
            ],
          ),

          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildRiwayatTab(AnakModel anak) {
    final diagnosisState = ref.watch(diagnosisByChildProvider(anak.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Riwayat Diagnosa
          _buildRiwayatSection(
            title: 'Riwayat Diagnosa',
            icon: Icons.chat_outlined,
            iconColor: AppConstants.primaryBlue,
            trailing: TextButton(
              onPressed: () => context.push('/diagnosa/${anak.id}'),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
            items: diagnosisState.isLoading
                ? [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ]
                : diagnosisState.diagnoses.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat diagnosa',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ]
                : diagnosisState.diagnoses
                      .take(5)
                      .map((d) => _buildDiagnosaItem(d))
                      .toList(),
          ),

          const SizedBox(height: 16),

          // Riwayat Terapi
          _buildRiwayatSection(
            title: 'Riwayat Terapi',
            icon: Icons.medical_services_outlined,
            iconColor: AppConstants.successColor,
            items: _isLoadingRiwayat
                ? [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ]
                : _therapySessions.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat terapi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ]
                : _therapySessions.take(10).map((s) {
                    final schedule = s['schedule'] != null
                        ? DateTime.parse(s['schedule'])
                        : DateTime.now();
                    final therapistName = s['therapist']?['name'] ?? 'Terapis';
                    final status = s['status'] ?? 'completed';
                    return _buildRiwayatItem(
                      date: schedule,
                      title: 'Terapi Wicara - ${therapistName}',
                      subtitle: status == 'completed' ? 'Selesai' : status,
                      status: status == 'completed' ? 'completed' : 'pending',
                    );
                  }).toList(),
          ),

          const SizedBox(height: 16),

          // Riwayat Game
          _buildRiwayatSection(
            title: 'Aktivitas Game',
            icon: Icons.games_outlined,
            iconColor: AppConstants.warningOrange,
            items: _isLoadingRiwayat
                ? [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ]
                : _gameLogs.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Belum ada aktivitas game',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ]
                : _gameLogs
                      .take(10)
                      .map(
                        (g) => _buildRiwayatItem(
                          date: g.playedAt,
                          title: g.gameType,
                          subtitle: 'Skor: ${g.gameScore}/100',
                          status: 'completed',
                        ),
                      )
                      .toList(),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDiagnosaItem(DiagnosisModel d) {
    final color = Color(d.riskLevelColorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/diagnosa/${d.childId}/${d.id}'),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                d.riskLevel == 'HIGH'
                    ? Icons.warning
                    : d.riskLevel == 'MEDIUM'
                    ? Icons.info_outline
                    : Icons.check_circle,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.riskLevelDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Skor: ${d.score}%  |  ${d.ageCategory}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatRelativeDate(d.createdAt),
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing,
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
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
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
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: isHighlight ? const EdgeInsets.all(12) : EdgeInsets.zero,
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
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
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
