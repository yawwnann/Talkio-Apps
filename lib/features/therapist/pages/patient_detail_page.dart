import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/progress_upload_model.dart';

/// Therapist Patient Detail Page
/// Halaman detail pasien untuk terapis menggunakan view single-scroll
class TherapistPatientDetailPage extends ConsumerStatefulWidget {
  final String patientId;

  const TherapistPatientDetailPage({super.key, required this.patientId});

  @override
  ConsumerState<TherapistPatientDetailPage> createState() =>
      _TherapistPatientDetailPageState();
}

class _TherapistPatientDetailPageState
    extends ConsumerState<TherapistPatientDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _patientDetail;
  List<dynamic> _progressNotes = [];
  List<ProgressUploadModel> _progressUploads = [];
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  bool _isSubmittingNote = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch patient detail, progress, and exercises in parallel
      final detailFuture = _apiService.getPatientDetail(widget.patientId);
      final progressFuture = _apiService.getPatientProgress(widget.patientId);
      final exercisesFuture = _apiService.getPatientExercises(widget.patientId);

      final results = await Future.wait([
        detailFuture,
        progressFuture,
        exercisesFuture,
      ]);

      if (results[0].statusCode == 200) {
        final detailData = results[0].data;
        if (detailData is Map<String, dynamic> && detailData['status'] == 'success') {
          _patientDetail = detailData['data'];
        }
      }

      if (results[1].statusCode == 200) {
        final progressData = results[1].data;
        if (progressData is Map<String, dynamic> && progressData['status'] == 'success') {
          _progressNotes = progressData['data']['progressNotes'] ?? [];
          final rawUploads = progressData['data']['progressUploads'] ?? [];
          _progressUploads = (rawUploads as List)
              .map((e) => ProgressUploadModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      if (results[2].statusCode == 200) {
        final exercisesData = results[2].data;
        if (exercisesData is Map<String, dynamic> && exercisesData['status'] == 'success') {
          _exercises = exercisesData['data'] ?? [];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isSubmittingNote = true;
    });

    try {
      final response = await _apiService.createNote(
        childId: widget.patientId,
        title: 'Catatan Sesi',
        content: _noteController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        _noteController.clear();
        _fetchPatientData(); // Refresh data
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan catatan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingNote = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_patientDetail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(title: const Text('Detail Pasien')),
        body: const Center(child: Text('Pasien tidak ditemukan')),
      );
    }

    final patientName = _patientDetail!['name'] ?? 'Pasien';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          patientName,
          style: GoogleFonts.poppins(
            color: AppConstants.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF64748B)),
            onPressed: () {
              // Action edit patient
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // White Container that fills the rest of the body
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Ringkasan Kemajuan'),
                    const SizedBox(height: 16),
                    _buildProgressCards(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Progress dari Orang Tua'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgressUploads(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Riwayat Latihan'),
                        Text(
                          'Lihat Semua',
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseHistory(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Laporan & Dokumen'),
                    const SizedBox(height: 16),
                    _buildReports(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Catatan Sesi'),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppConstants.lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSessionNotes(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TherapistBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final patientName = _patientDetail!['name'] ?? 'Pasien';
    final dateOfBirthStr = _patientDetail!['dateOfBirth'];
    final dateOfBirth = dateOfBirthStr != null ? DateTime.parse(dateOfBirthStr) : DateTime.now();

    return Column(
      children: [
        // Avatar with Badge
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileAvatar(
                name: patientName,
                radius: 40,
              ),
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32), // Green color for AKTIF
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AKTIF',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Name
        Center(
          child: Text(
            patientName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ID Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'ID: LK-2024-039',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Usia and Diagnosis
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'USIA',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _calculateAge(dateOfBirth),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'DIAGNOSIS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keterlambatan Bicara -\nSedang',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFF1F5F9),
        ),
        const SizedBox(height: 16),
        // Last Session
        Center(
          child: Column(
            children: [
              Text(
                'SESI TERAKHIR',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '12 Okt 2023',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCards() {
    return Column(
      children: [
        _buildSingleProgressCard(
          icon: Icons.record_voice_over,
          color: AppConstants.primaryBlue,
          bgColor: const Color(0xFFF0F5FF),
          title: 'Kejelasan',
          increase: '+12% Bulan ini',
          value: 0.65,
        ),
        const SizedBox(height: 12),
        _buildSingleProgressCard(
          icon: Icons.menu_book,
          color: const Color(0xFF16A34A), // Green
          bgColor: const Color(0xFFF0FDF4),
          title: 'Kosakata',
          increase: '+5% Bulan ini',
          value: 0.40,
        ),
        const SizedBox(height: 12),
        _buildSingleProgressCard(
          icon: Icons.forum,
          color: const Color(0xFFD97706), // Gold/Brown
          bgColor: const Color(0xFFFFFBEB),
          title: 'Interaksi',
          increase: '+18% Bulan ini',
          value: 0.82,
        ),
      ],
    );
  }

  Widget _buildSingleProgressCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String increase,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Text(
                increase,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 36,
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressUploads() {
    if (_progressUploads.isEmpty) {
      return Text(
        'Belum ada progress yang diunggah oleh orang tua.',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      );
    }
    
    return Column(
      children: _progressUploads.map((upload) {
        final IconData icon;
        final Color iconColor;
        final Color bgColor;
        
        if (upload.isVideo) {
          icon = Icons.videocam;
          iconColor = AppConstants.primaryBlue;
          bgColor = AppConstants.primaryBlue.withValues(alpha: 0.1);
        } else if (upload.isAudio) {
          icon = Icons.mic;
          iconColor = const Color(0xFF4A90E2);
          bgColor = const Color(0xFF4A90E2).withValues(alpha: 0.1);
        } else {
          icon = Icons.image;
          iconColor = const Color(0xFF16A34A);
          bgColor = const Color(0xFF16A34A).withValues(alpha: 0.1);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upload.formattedDateTime,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          upload.parentNotes ?? 'Tidak ada catatan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (upload.duration != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Durasi: ${upload.durationLabel}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: AppConstants.primaryBlue,
                    onPressed: () => _openMediaPreview(upload),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openMediaPreview(ProgressUploadModel upload) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (upload.isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(upload.fileUrl, fit: BoxFit.contain),
              )
            else if (upload.isVideo)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.videocam, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Video: ${upload.formattedDate}',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      upload.fileUrl,
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.mic, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Rekaman Suara: ${upload.formattedDate}',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                    if (upload.duration != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Durasi: ${upload.durationLabel}',
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHistory() {
    return Column(
      children: [
        _buildExerciseItem(
          icon: Icons.mic,
          color: AppConstants.primaryBlue,
          bgColor: const Color(0xFFF0F5FF),
          title: 'Latihan Huruf S',
          subtitle: 'Kemarin • 15:30 • 0:45s',
        ),
        const SizedBox(height: 12),
        _buildExerciseItem(
          icon: Icons.extension,
          color: const Color(0xFF16A34A), // Green puzzle
          bgColor: const Color(0xFFF0FDF4),
          title: 'Tebak Hewan',
          subtitle: '14 Okt 2023 • 10:15 • 2:10s',
        ),
        const SizedBox(height: 12),
        _buildExerciseItem(
          icon: Icons.emoji_events,
          color: const Color(0xFFD97706), // Gold trophy
          bgColor: const Color(0xFFFFFBEB),
          title: 'Pengulangan Kata Kerja',
          subtitle: '12 Okt 2023 • 16:00 • 1:30s',
        ),
      ],
    );
  }

  Widget _buildExerciseItem({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppConstants.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildReports() {
    return Column(
      children: [
        _buildReportItem('Laporan Bulanan - September', 'PDF • 1,2 MB'),
        const SizedBox(height: 12),
        _buildReportItem('Hasil Observasi Awal', 'PDF • 2,6 MB'),
      ],
    );
  }

  Widget _buildReportItem(String title, String details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFFDC2626),
            size: 28,
          ), // Red PDF Icon
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: Color(0xFF64748B),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNotes() {
    return Column(
      children: [
        if (_progressNotes.isEmpty)
          Text(
            'Belum ada catatan sesi.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          )
        else
          ..._progressNotes.asMap().entries.map((entry) {
            final int index = entry.key;
            final dynamic note = entry.value;
            final bool isPrimary = index == 0;
            final bool isLast = index == _progressNotes.length - 1;
            final String date = note['date'] != null 
                ? note['date'].toString().split('T')[0] 
                : '';
            
            return _buildTimelineItem(
              date: date,
              content: note['content'] ?? '',
              author: 'Terapis',
              isPrimary: isPrimary,
              isLast: isLast,
            );
          }),
        const SizedBox(height: 24),
        // Text Input for New Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambah catatan baru...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // Action save note
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: Text(
              'Simpan Catatan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String content,
    required String author,
    required bool isPrimary,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPrimary
                      ? AppConstants.primaryBlue
                      : const Color(0xFFCBD5E1),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPrimary
                        ? AppConstants.primaryBlue.withValues(alpha: 0.3)
                        : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? AppConstants.primaryBlue
                          : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return '$years Tahun $months Bulan';
    } else {
      return '$months Bulan';
    }
  }
}
