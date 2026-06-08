import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../anak/providers/anak_provider.dart';

/// Therapist Patient Page
/// Halaman daftar pasien untuk terapis
class TherapistPatientPage extends ConsumerStatefulWidget {
  const TherapistPatientPage({super.key});

  @override
  ConsumerState<TherapistPatientPage> createState() =>
      _TherapistPatientPageState();
}

class _TherapistPatientPageState extends ConsumerState<TherapistPatientPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(anakProvider.notifier).fetchAllAnak();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final allAnak = anakState.anakList;

    // Filter anak based on search query and filter selection
    final filteredAnak = allAnak.where((anak) {
      final name = anak.name.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query);

      final status = anak.sessionStatus ?? '';
      final isDone = status == 'COMPLETED' || status == 'CANCELLED';
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && !isDone) ||
          (_selectedFilter == 'completed' && isDone);

      return matchesSearch && matchesFilter;
    }).toList();

    // Calculate stats
    final totalCount = allAnak.length;
    final activeCount = allAnak.where((a) {
      final status = a.sessionStatus ?? '';
      return status != 'COMPLETED' && status != 'CANCELLED';
    }).length;
    final completedCount = allAnak.where((a) {
      final status = a.sessionStatus ?? '';
      return status == 'COMPLETED' || status == 'CANCELLED';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(totalCount, activeCount, completedCount),
          Expanded(
            child: anakState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAnak.isEmpty
                    ? _buildEmptyState()
                    : _buildPatientList(filteredAnak),
          ),
        ],
      ),
      bottomNavigationBar: const TherapistBottomNav(currentIndex: 1),
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
            'Daftar Pasien',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          Text(
            'Kelola perkembangan pasien',
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
          onPressed: () => ref.read(anakProvider.notifier).fetchAllAnak(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryBlue, AppConstants.lightBlue],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari nama pasien...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(int total, int active, int completed) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'all', total, AppConstants.primaryBlue),
            const SizedBox(width: 8),
            _buildFilterChip('Aktif', 'active', active, const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _buildFilterChip('Selesai', 'completed', completed, const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, int count, Color color) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          '$count $label',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientList(List<dynamic> pasien) {
    return RefreshIndicator(
      onRefresh: () => ref.read(anakProvider.notifier).fetchAllAnak(),
      color: AppConstants.primaryBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: pasien.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildPatientCard(pasien[index]),
      ),
    );
  }

  Widget _buildPatientCard(dynamic anak) {
    final status = anak.sessionStatus ?? '';
    final isDone = status == 'COMPLETED' || status == 'CANCELLED';
    final statusText = isDone ? 'Selesai' : 'Aktif';
    final statusColor = isDone ? const Color(0xFF6B7280) : const Color(0xFF10B981);
    final totalSessions = anak.totalSessions ?? 0;

    String lastSessionStr = 'Belum ada sesi';
    if (anak.lastSessionDate != null) {
      try {
        final d = DateTime.parse(anak.lastSessionDate.toString());
        lastSessionStr = DateFormat('dd MMM yyyy', 'id_ID').format(d);
      } catch (e) {
        lastSessionStr = 'Tidak diketahui';
      }
    }

    return InkWell(
      onTap: () => context.push('/therapist/pasien/${anak.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? const Color(0xFFE5E7EB) : statusColor.withValues(alpha: 0.3),
          ),
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
            ProfileAvatar(
              name: anak.name,
              radius: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anak.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $totalSessions sesi',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terakhir: $lastSessionStr',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppConstants.primaryBlue,
              ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 40,
              color: AppConstants.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Pasien',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pasien akan muncul setelah ada booking\nterapi dari orang tua',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}