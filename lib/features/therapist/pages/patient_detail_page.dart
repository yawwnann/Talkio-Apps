import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
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
  List<dynamic> _reports = [];
  bool _isLoading = true;
  bool _isSubmittingNote = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

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
      // Fetch patient detail, progress, exercises, and reports in parallel
      final detailFuture = _apiService.getPatientDetail(widget.patientId);
      final progressFuture = _apiService.getPatientProgress(widget.patientId);
      final exercisesFuture = _apiService.getPatientExercises(widget.patientId);
      final reportsFuture = _apiService.getReportHistory();

      final results = await Future.wait([
        detailFuture,
        progressFuture,
        exercisesFuture,
        reportsFuture,
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

      if (results[3].statusCode == 200) {
        final reportsData = results[3].data;
        if (reportsData is Map<String, dynamic> && reportsData['status'] == 'success') {
          final allReports = reportsData['data'] as List? ?? [];
          _reports = allReports.where((r) => r['patient_id'] == widget.patientId).toList();
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
    final diagnoses = _patientDetail!['diagnoses'] as List? ?? [];
    final diagnosisLabel = diagnoses.isNotEmpty
        ? diagnoses.map((d) => d['label'] ?? d['result'] ?? '').join(', ')
        : 'Belum ada diagnosis';
    final sessions = _patientDetail!['therapySessions'] as List? ?? [];
    String lastSessionStr = 'Belum ada sesi';
    if (sessions.isNotEmpty) {
      final sorted = List<Map<String, dynamic>>.from(sessions)
        ..sort((a, b) {
          final da = DateTime.tryParse(a['schedule'] ?? '');
          final db = DateTime.tryParse(b['schedule'] ?? '');
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });
      final last = sorted.first['schedule'];
      if (last != null) {
        final d = DateTime.parse(last.toString());
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        lastSessionStr = '${d.day} ${months[d.month - 1]} ${d.year}';
      }
    }

    return Column(
      children: [
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
                      color: const Color(0xFF2E7D32),
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
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${sessions.length} sesi terapi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
                    diagnosisLabel,
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
                lastSessionStr,
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
    if (upload.isVideo) {
      // Initialize video player
      _videoController = VideoPlayerController.networkUrl(Uri.parse(upload.fileUrl));
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat video',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                Text(
                  errorMessage,
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

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
                  onPressed: () {
                    _chewieController?.dispose();
                    _videoController?.dispose();
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Video dari ${upload.formattedDate}',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ).then((_) {
        _chewieController?.dispose();
        _videoController?.dispose();
      });
    } else if (upload.isImage) {
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
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    upload.fileUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 48),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Audio
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement audio playback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur pemutar audio sedang dikembangkan')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Putar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildExerciseHistory() {
    if (_exercises.isEmpty) {
      return Text(
        'Belum ada riwayat latihan.',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      );
    }

    return Column(
      children: _exercises.take(5).map((e) {
        final gameName = e['gameName'] ?? e['gameType'] ?? 'Latihan';
        final playedAt = e['playedAt'] ?? e['createdAt'];
        final score = e['score'];
        String subtitle = '';
        if (playedAt != null) {
          final d = DateTime.parse(playedAt.toString());
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
          subtitle = '${d.day} ${months[d.month - 1]} ${d.year}';
        }
        if (score != null) subtitle += ' • Skor: $score';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sports_esports, color: AppConstants.primaryBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReports() {
    if (_reports.isEmpty) {
      return Text(
        'Belum ada laporan.',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      );
    }

    return Column(
      children: _reports.map((r) {
        final title = r['title'] ?? r['summary'] ?? 'Laporan';
        final date = r['date'] ?? '';
        final status = r['status'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 28),
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
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.file_download_outlined, color: Color(0xFF64748B), size: 24),
            ],
          ),
        );
      }).toList(),
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
            onPressed: _isSubmittingNote ? null : _submitNote,
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
