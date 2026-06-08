import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/diagnosis_provider.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/diagnosis_model.dart';

class DiagnosaHistoryPage extends ConsumerStatefulWidget {
  final String? childId;

  const DiagnosaHistoryPage({super.key, this.childId});

  @override
  ConsumerState<DiagnosaHistoryPage> createState() => _DiagnosaHistoryPageState();
}

class _DiagnosaHistoryPageState extends ConsumerState<DiagnosaHistoryPage> with WidgetsBindingObserver {
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedChildId = widget.childId;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes (user comes back to this page)
    if (state == AppLifecycleState.resumed && _selectedChildId != null) {
      ref.invalidate(diagnosisByChildProvider(_selectedChildId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final diagnosisState = _selectedChildId != null
        ? ref.watch(diagnosisByChildProvider(_selectedChildId!))
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppConstants.primaryBlue),
        title: Text(
          'Riwayat Deteksi',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_selectedChildId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(diagnosisByChildProvider(_selectedChildId!));
              },
            ),
        ],
      ),
      body: _selectedChildId == null
          ? _buildChildSelector(anakState)
          : _buildDiagnosisList(diagnosisState, anakState),
    );
  }

  Widget _buildChildSelector(AnakState anakState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Pilih Anak',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          if (anakState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (anakState.anakList.isEmpty)
            Text('Belum ada data anak.', style: GoogleFonts.poppins(color: Colors.red))
          else
            ...anakState.anakList.map((anak) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: CircleAvatar(
                  backgroundColor: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  child: Text(anak.name[0], style: GoogleFonts.poppins(color: AppConstants.primaryBlue, fontWeight: FontWeight.w600)),
                ),
                title: Text(anak.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${anak.ageInMonths} bulan', style: GoogleFonts.poppins(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() => _selectedChildId = anak.id);
                },
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildDiagnosisList(DiagnosisState? state, AnakState anakState) {
    if (state == null) return const SizedBox.shrink();

    final anak = anakState.anakList.where((a) => a.id == _selectedChildId).firstOrNull;

    return Column(
      children: [
        if (anak != null)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Text('Anak: ', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                Text(anak.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryBlue)),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _selectedChildId = null),
                  child: Text('Ganti', style: GoogleFonts.poppins(fontSize: 12, color: AppConstants.primaryBlue)),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.isLoading && state.diagnoses.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.diagnoses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('Belum ada riwayat diagnosa', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8))),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/konsultasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            icon: const Icon(Icons.psychology, color: Colors.white, size: 20),
                            label: Text('Mulai Deteksi Sekarang', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(diagnosisByChildProvider(_selectedChildId!));
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.diagnoses.length,
                        itemBuilder: (context, index) => _buildDiagnosisCard(state.diagnoses[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(DiagnosisModel d) {
    final color = Color(d.riskLevelColorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/diagnosa/$_selectedChildId/${d.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    d.riskLevel == 'HIGH' ? Icons.warning : d.riskLevel == 'MEDIUM' ? Icons.info_outline : Icons.check_circle,
                    color: color, size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.riskLevelDisplay, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                      const SizedBox(height: 2),
                      Text('Skor: ${d.score}%  |  ${d.ageCategory}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Text(
                  _formatDate(d.createdAt),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
