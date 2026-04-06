import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
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
  String _selectedFilter = 'Semua Pasien';

  final List<String> _filters = ['Semua Pasien', 'Aktif Terapi', 'Selesai Sesi'];

  @override
  void initState() {
    super.initState();
    // Load patients for therapist
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

    // Filter anak based on search query and chip selection
    final filteredAnak = allAnak.where((anak) {
      final name = anak.name.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query);
      
      final isDone = (anak.hashCode % 3 == 0); // Mock logic for 'Selesai Sesi'
      final matchesFilter = _selectedFilter == 'Semua Pasien' || 
          (_selectedFilter == 'Selesai Sesi' && isDone) || 
          (_selectedFilter == 'Aktif Terapi' && !isDone);

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Daftar Pasien',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 24),
            filteredAnak.isEmpty
                ? _buildEmptyState(anakState.isLoading)
                : _buildPatientList(filteredAnak),
            const SizedBox(height: 80), // Fab spacing
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF005BAC), // primaryBlue
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.person_add, color: Colors.white, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: TherapistBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryBlue,
            AppConstants.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
            'Kelola\nPerkembangan Si\nKecil',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Temukan dan pantau setiap langkah\nkecil menuju kemajuan yang besar.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama pasien...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.tune, color: AppConstants.primaryBlue, size: 20),
              label: Text(
                'Filter',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryBlue,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF005BAC) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPatientList(List<dynamic> pasien) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pasien.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPatientCard(pasien[index]);
      },
    );
  }

  Widget _buildPatientCard(dynamic anak) {
    // Determine status (use hashCode logic for display variety)
    final isDone = (anak.hashCode % 3 == 0);
    final statusText = isDone ? 'SELESAI SESI' : 'AKTIF TERAPI';
    final statusColor = isDone ? const Color(0xFF94A3B8) : const Color(0xFF16A34A);
    final progress = isDone ? 0.92 : ((anak.hashCode % 50) + 40) / 100.0;
    
    // Choose progress label
    final progressLabels = ['Kejelasan Bicara', 'Kosakata', 'Interaksi Sosial', 'Kejelasan Artikulasi'];
    final progressLabel = progressLabels[anak.hashCode % progressLabels.length];
    
    // Avatar colors
    final avatarColor = [
      const Color(0xFF26A69A), // teal
      const Color(0xFF5C6BC0), // indigo
      const Color(0xFFEC407A), // pink
      const Color(0xFFFFCA28), // amber
    ][anak.name.length % 4];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    anak.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anak.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                progressLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDone ? const Color(0xFF2E7D32) : AppConstants.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? const Color(0xFF1B5E20) : AppConstants.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                'Sesi Terakhir: 12 Okt 2023',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => context.push('/therapist/pasien/${anak.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005BAC), // primary blue
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Lihat Detail',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCA28), // yellow map
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_none, color: Color(0xFF1E293B), size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator()
        )
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: AppConstants.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Pasien',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar pasien akan muncul setelah\norang tua mendaftarkan anak',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
