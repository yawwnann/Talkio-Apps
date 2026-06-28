import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/loading_widget.dart';

class ParentReportListPage extends ConsumerStatefulWidget {
  const ParentReportListPage({super.key});

  @override
  ConsumerState<ParentReportListPage> createState() => _ParentReportListPageState();
}

class _ParentReportListPageState extends ConsumerState<ParentReportListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  String? _selectedChildId;
  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      
      // Fetch reports
      final response = await apiService.dio.get('/parent/reports');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final reportsData = data['data'] as List<dynamic>;
          
          setState(() {
            _reports = reportsData.cast<Map<String, dynamic>>();
            // Extract unique children
            _children = _reports.fold<List<Map<String, dynamic>>>([], (list, report) {
              final childId = report['childId'];
              if (!list.any((c) => c['id'] == childId)) {
                list.add({
                  'id': childId,
                  'name': report['childName'],
                });
              }
              return list;
            });
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedChildId == null) return _reports;
    return _reports.where((r) => r['childId'] == _selectedChildId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : Column(
              children: [
                if (_children.isNotEmpty) _buildChildFilter(),
                Expanded(
                  child: filteredReports.isEmpty
                      ? _buildEmptyState()
                      : _buildReportList(filteredReports),
                ),
              ],
            ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Perkembangan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            '${_filteredReports.length} laporan',
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

  Widget _buildChildFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // All children option
            GestureDetector(
              onTap: () => setState(() => _selectedChildId = null),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedChildId == null ? AppConstants.primaryBlue : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: _selectedChildId == null ? FontWeight.w600 : FontWeight.w400,
                    color: _selectedChildId == null ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            // Individual children
            ..._children.map((child) {
              final isSelected = _selectedChildId == child['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedChildId = child['id']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryBlue : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    child['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
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
        statusLabel = status ?? 'Unknown';
    }

    return GestureDetector(
      onTap: () {
        context.push('/laporan/${report['id']}');
      },
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
            const SizedBox(height: 12),
            Row(
              children: [
                ProfileAvatar(
                  name: report['childName'],
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'] ?? 'Laporan Perkembangan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
            if (report['content'] != null && report['content'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report['content'].toString().length > 100
                      ? '${report['content'].toString().substring(0, 100)}...'
                      : report['content'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  'Therapist: ${report['therapistName'] ?? '-'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
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
            'Belum ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Laporan akan muncul setelah therapist mengirim',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
