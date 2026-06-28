import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_report_provider.dart';

class AdminReportPage extends ConsumerStatefulWidget {
  const AdminReportPage({super.key});

  @override
  ConsumerState<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends ConsumerState<AdminReportPage> {
  int _selectedTab = 0; // 0 = Semua, 1 = Terkirim, 2 = Draft
  final List<String> _tabs = ['Semua', 'Terkirim', 'Draft'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDownloading = false;

  List<Map<String, dynamic>> get _filteredReports {
    final reports = ref.watch(adminReportProvider).reports;
    return reports.where((report) {
      final childName = report['childName']?.toString().toLowerCase() ?? '';
      final therapistName = report['therapistName']?.toString().toLowerCase() ?? '';
      final matchesSearch = childName.contains(_searchQuery.toLowerCase()) ||
          therapistName.contains(_searchQuery.toLowerCase());
      final matchesTab = _selectedTab == 0 ||
          (_selectedTab == 1 && report['status'] == 'SENT') ||
          (_selectedTab == 2 && report['status'] == 'DRAFT');
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminReportProvider.notifier).fetchReports();
    });
  }

  Future<void> _fetchReports() async {
    await ref.read(adminReportProvider.notifier).fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportProvider);
    final filteredReports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          _buildSummaryCards(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: LoadingWidget())
                : filteredReports.isEmpty
                    ? _buildEmptyState()
                    : _buildReportList(filteredReports),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar(AdminReportState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manajemen Laporan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            '${state.total} laporan',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 22),
          onPressed: _fetchReports,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari nama pasien atau terapis...',
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: Colors.white,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCards(AdminReportState state) {
    final sentCount = state.summary['sent'] ?? 0;
    final draftCount = state.summary['draft'] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryChip('Terkirim', sentCount, const Color(0xFF10B981)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip('Draft', draftCount, const Color(0xFFF59E0B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<Map<String, dynamic>> reports) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'];
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'SENT':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Terkirim';
        break;
      case 'DRAFT':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Draft';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusLabel = status;
    }

    return GestureDetector(
      onTap: () => _showReportDetail(report),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  report['date'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ProfileAvatar(name: report['childName'], radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'] ?? 'Laporan Perkembangan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        report['childName'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Terapis: ${report['therapistName'] ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetail(Map<String, dynamic> report) {
    final status = report['status'];
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'SENT':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Terkirim';
        break;
      case 'DRAFT':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Draft';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusLabel = status;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Detail Laporan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', report['id']),
              _buildDetailRow('Status', statusLabel, color: statusColor),
              const Divider(),
              _buildDetailRow('Pasien', report['childName']),
              _buildDetailRow('Terapis', report['therapistName']),
              const Divider(),
              _buildDetailRow('Judul', report['title']),
              _buildDetailRow('Tanggal', report['date']),
              if (report['content'] != null && report['content'].toString().isNotEmpty) ...[
                const Divider(),
                Text(
                  'Isi Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report['content'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.poppins(color: AppConstants.primaryBlue)),
          ),
          if (report['childId'] != null)
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : () async {
                final childId = report['childId'];
                final token = StorageService.getString(AppConstants.tokenKey);
                if (token == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesi login telah habis')),
                  );
                  return;
                }

                setState(() => _isDownloading = true);
                Navigator.pop(context);

                try {
                  final dio = Dio();
                  final url = '${AppConstants.baseUrl}/therapist/report/$childId';
                  final dir = await getTemporaryDirectory();
                  final childName = report['childName'] ?? 'anak';
                  final filePath = '${dir.path}/Laporan-Perkembangan-$childName.pdf';

                  await dio.download(
                    url,
                    filePath,
                    options: Options(
                      headers: {'Authorization': 'Bearer $token'},
                      responseType: ResponseType.bytes,
                    ),
                  );

                  if (!mounted) return;

                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuka PDF: ${result.message}')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengunduh PDF: ${e.toString().replaceAll('Exception: ', '')}')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isDownloading = false);
                  }
                }
              },
              icon: _isDownloading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(
                _isDownloading ? 'Mengunduh...' : 'Download PDF',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
