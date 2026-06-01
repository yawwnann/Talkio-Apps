import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/services/api_service.dart';
import '../../anak/providers/anak_provider.dart';

class GameHistoryPage extends ConsumerStatefulWidget {
  const GameHistoryPage({super.key});

  @override
  ConsumerState<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends ConsumerState<GameHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // Data state
  AnakModel? _selectedChild;
  List<dynamic> _gameLogs = [];
  List<dynamic> _artikulasiSessions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(anakProvider.notifier).fetchAllAnak();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(String childId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getArtikulasiSessions(childId),
        _apiService.getGameHistory(childId),
      ]);

      List<dynamic> tempArtikulasi = [];
      List<dynamic> tempGameLogs = [];

      // Parse artikulasi response
      if (results[0].statusCode == 200) {
        final data = results[0].data;
        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic>) {
            final sessions = data['data']['sessions'];
            if (sessions is List) tempArtikulasi = sessions;
          }
        }
      }

      // Parse game logs response
      if (results[1].statusCode == 200) {
        final data = results[1].data;
        if (data is List) {
          tempGameLogs = data;
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          tempGameLogs = data['data'];
        }
      }

      setState(() {
        _artikulasiSessions = tempArtikulasi;
        _gameLogs = tempGameLogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final children = anakState.anakList;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Riwayat Game',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              if (children.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        hint: Text(
                          'Pilih Anak',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _selectedChild?.id,
                        items: children.map((AnakModel child) {
                          return DropdownMenuItem<String>(
                            value: child.id,
                            child: Text(
                              child.name,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? childId) {
                          if (childId != null) {
                            final child = children.firstWhere((c) => c.id == childId);
                            setState(() => _selectedChild = child);
                            _fetchData(childId);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                labelColor: AppConstants.primaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppConstants.primaryBlue,
                tabs: const [
                  Tab(text: 'Artikulasi'),
                  Tab(text: 'Game Lainnya'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _selectedChild == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih anak untuk melihat riwayat',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildArtikulasiTab(),
                    _buildGameLogsTab(),
                  ],
                ),
    );
  }

  Widget _buildArtikulasiTab() {
    if (_artikulasiSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat artikulasi',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedChild != null) {
          await _fetchData(_selectedChild!.id);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _artikulasiSessions.length,
        itemBuilder: (context, index) {
          return _buildArtikulasiCard(_artikulasiSessions[index]);
        },
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Unknown';
    }
  }

  Widget _buildArtikulasiCard(dynamic session) {
    final word = session['targetWord'] ?? '';
    final sound = session['targetSound'] ?? '';
    final therapistRating = session['therapistRating'] as String?;
    final therapistScore = session['therapistScore'] as int?;
    final therapistNotes = session['therapistNotes'] as String?;
    final createdAt = session['createdAt']?.toString() ?? '';
    final dateTimeStr = _formatDateTime(createdAt);

    final bool isReviewed = therapistRating != null;
    final bool isOke = therapistRating == 'OKE';

    final Color statusColor = isReviewed
        ? (isOke ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
        : const Color(0xFFD97706);

    final IconData statusIcon = isReviewed
        ? Icons.check_circle
        : Icons.pending;

    final String statusLabel = therapistRating == 'OKE'
        ? 'Oke'
        : therapistRating == 'BELUM_OK'
            ? 'Perlu Latihan'
            : 'Menunggu Review';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReviewed
              ? statusColor.withValues(alpha: 0.3)
              : Colors.grey.shade300,
          width: isReviewed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.mic,
                  color: const Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Bunyi $sound • $dateTimeStr',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (therapistScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$therapistScore/100',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Review status badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (therapistNotes != null && therapistNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      therapistNotes,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameLogsTab() {
    if (_gameLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.games, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat game',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedChild != null) {
          await _fetchData(_selectedChild!.id);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gameLogs.length,
        itemBuilder: (context, index) {
          return _buildGameLogCard(_gameLogs[index]);
        },
      ),
    );
  }

  Widget _buildGameLogCard(dynamic log) {
    final gameType = log['gameType']?.toString() ?? 'Unknown';
    final score = log['gameScore'] ?? 0;
    final playedAt = log['playedAt']?.toString() ?? '';
    final dateTimeStr = _formatDateTime(playedAt);

    IconData icon;
    Color color;
    switch (gameType.toLowerCase()) {
      case 'suara binatang':
        icon = Icons.pets;
        color = const Color(0xFF8B5CF6);
        break;
      case 'tebak suara':
        icon = Icons.hearing;
        color = const Color(0xFF10B981);
        break;
      case 'kata bergambar':
        icon = Icons.image;
        color = const Color(0xFF3B82F6);
        break;
      case 'cerita interaktif':
        icon = Icons.auto_stories;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.games;
        color = AppConstants.primaryBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameType,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  dateTimeStr,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⭐ $score',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
