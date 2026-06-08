import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../anak/providers/anak_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/progress_upload_model.dart';

/// Therapist Patient Detail Page
/// Halaman detail pasien untuk terapis menggunakan view single-scroll
class TherapistPatientDetailPage extends ConsumerStatefulWidget {
  final String patientId;
  final String? openTab; // 'progress' to open progress tab

  const TherapistPatientDetailPage({
    super.key,
    required this.patientId,
    this.openTab,
  });

  @override
  ConsumerState<TherapistPatientDetailPage> createState() =>
      _TherapistPatientDetailPageState();
}

class _TherapistPatientDetailPageState
    extends ConsumerState<TherapistPatientDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _patientDetail;
  List<dynamic> _progressNotes = [];
  List<ProgressUploadModel> _progressUploads = [];
  List<dynamic> _exercises = [];
  List<dynamic> _reports = [];

  // Artikulasi state
  Map<String, dynamic>? _artikulasiData;
  List<dynamic> _artikulasiSessions = [];
  Map<String, dynamic> _artikulasiSoundStats = {};
  int _needsReview = 0;

  // Audio player for artikulasi
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingSessionId;
  bool _isPlayingAudio = false;

  bool _isLoading = true;
  bool _isSubmittingNote = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  void _scrollToProgressTab() {
    // Scroll to progress section if openTab is 'progress'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openTab == 'progress' && _scrollController.hasClients) {
        // Calculate approximate position for progress section
        _scrollController.animateTo(
          600, // Approximate position
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch patient detail, progress, exercises, reports, and artikulasi in parallel
      final detailFuture = _apiService.getPatientDetail(widget.patientId);
      final progressFuture = _apiService.getPatientProgress(widget.patientId);
      final exercisesFuture = _apiService.getPatientExercises(widget.patientId);
      final reportsFuture = _apiService.getReportHistory();
      final artikulasiFuture = _apiService.getArtikulasiSummary(
        widget.patientId,
      );

      final results = await Future.wait([
        detailFuture,
        progressFuture,
        exercisesFuture,
        reportsFuture,
        artikulasiFuture,
      ]);

      if (results[0].statusCode == 200) {
        final detailData = results[0].data;
        if (detailData is Map<String, dynamic> &&
            detailData['status'] == 'success') {
          _patientDetail = detailData['data'];
        }
      }

      if (results[1].statusCode == 200) {
        final progressData = results[1].data;
        if (progressData is Map<String, dynamic> &&
            progressData['status'] == 'success') {
          _progressNotes = progressData['data']['progressNotes'] ?? [];
          final rawUploads = progressData['data']['progressUploads'] ?? [];
          _progressUploads = (rawUploads as List)
              .map(
                (e) =>
                    ProgressUploadModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
      }

      if (results[2].statusCode == 200) {
        final exercisesData = results[2].data;
        if (exercisesData is Map<String, dynamic> &&
            exercisesData['status'] == 'success') {
          _exercises = exercisesData['data'] ?? [];
        }
      }

      if (results[3].statusCode == 200) {
        final reportsData = results[3].data;
        if (reportsData is Map<String, dynamic> &&
            reportsData['status'] == 'success') {
          final allReports = reportsData['data'] as List? ?? [];
          _reports = allReports
              .where((r) => r['patient_id'] == widget.patientId)
              .toList();
        }
      }

      // Process artikulasi data
      if (results[4].statusCode == 200) {
        final artikulasiData = results[4].data;
        if (artikulasiData is Map<String, dynamic> &&
            artikulasiData['status'] == 'success') {
          _artikulasiData = artikulasiData['data'];
          _artikulasiSoundStats = _artikulasiData?['soundStats'] ?? {};
          _artikulasiSessions = _artikulasiData?['latestSessions'] ?? [];
          _needsReview = _artikulasiData?['needsReview'] ?? 0;
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
        _scrollToProgressTab();
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
    _audioPlayer.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
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
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileCard(),
            const SizedBox(height: 20),

            // Quick Stats Row
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Progress dari Orang Tua Section
            _buildSectionCard(
              title: 'Progress dari Orang Tua',
              icon: Icons.cloud_upload_rounded,
              iconColor: const Color(0xFF3B82F6),
              child: _buildProgressUploads(),
              isEmpty: _progressUploads.isEmpty,
              emptyMessage: 'Belum ada progress yang diunggah.',
            ),
            const SizedBox(height: 16),

            // Progress Artikulasi Section
            _buildArtikulasiSection(),
            const SizedBox(height: 16),

            // Catatan & Laporan Section (merged)
            _buildCatatanLaporanSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: TherapistBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required bool isEmpty,
    required String emptyMessage,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isEmpty
                ? Text(
                    emptyMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  )
                : child,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final patientName = _patientDetail!['name'] ?? 'Pasien';
    final diagnoses = _patientDetail!['diagnoses'] as List? ?? [];
    final diagnosisLabel = diagnoses.isNotEmpty
        ? diagnoses.map((d) => d['label'] ?? d['result'] ?? '').join(', ')
        : 'Belum ada';
    final sessions = _patientDetail!['therapySessions'] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppConstants.primaryBlue, Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AKTIF',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sessions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sesi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    diagnosisLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final sessions = _patientDetail!['therapySessions'] as List? ?? [];
    final lastSession = sessions.isNotEmpty
        ? _getLastSessionDate(sessions)
        : null;
    final dateOfBirthStr = _patientDetail!['dateOfBirth'];
    final age = dateOfBirthStr != null
        ? _calculateAge(DateTime.parse(dateOfBirthStr))
        : '-';

    return Row(
      children: [
        Expanded(child: _buildStatItem('Usia', age, Icons.cake_outlined)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Sesi Terakhir',
            lastSession ?? '-',
            Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Progress',
            '${_progressUploads.length}',
            Icons.trending_up_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryBlue, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  String _getLastSessionDate(List sessions) {
    if (sessions.isEmpty) return '-';
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
    if (last == null) return '-';
    final d = DateTime.parse(last.toString());
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
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

  Widget _buildProgressUploads() {
    if (_progressUploads.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada progress',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _progressUploads.take(3).map((upload) {
        final IconData icon = upload.isVideo
            ? Icons.videocam
            : (upload.isAudio ? Icons.mic : Icons.image);
        final Color iconColor = upload.isVideo
            ? const Color(0xFF3B82F6)
            : (upload.isAudio
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF16A34A));
        final Color bgColor = iconColor.withValues(alpha: 0.1);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.formattedDateTime,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      upload.parentNotes ?? 'Tanpa catatan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (upload.duration != null)
                      Text(
                        'Durasi: ${upload.durationLabel}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: iconColor,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_outline, size: 22),
                color: iconColor,
                onPressed: () => _openMediaPreview(upload),
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
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(upload.fileUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // Show loading dialog first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat video...',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      );

      _videoController!
          .initialize()
          .then((_) {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: true,
              looping: false,
              aspectRatio: _videoController!.value.aspectRatio,
              allowFullScreen: true,
              allowMuting: true,
              showControls: true,
              placeholder: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
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
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );

            // Close loading dialog and show video
            Navigator.of(context, rootNavigator: true).pop();

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
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: Chewie(controller: _chewieController!),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Video dari ${upload.formattedDate}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).then((_) {
              _chewieController?.dispose();
              _videoController?.dispose();
            });
          })
          .catchError((error) {
            // Close loading dialog and show error
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memuat video: $error'),
                backgroundColor: Colors.red,
              ),
            );
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
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement audio playback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur pemutar audio sedang dikembangkan',
                        ),
                      ),
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
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada riwayat',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _exercises.take(3).map((e) {
        final gameName = e['gameName'] ?? e['gameType'] ?? 'Latihan';
        final playedAt = e['playedAt'] ?? e['createdAt'];
        String dateStr = '-';
        if (playedAt != null) {
          final d = DateTime.parse(playedAt.toString());
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des',
          ];
          dateStr = '${d.day} ${months[d.month - 1]}';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sports_esports,
                  color: AppConstants.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (e['score'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${e['score']}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCatatanLaporanSection() {
    final merged = _getMergedEntries();

    return _buildSectionCard(
      title: 'Catatan & Laporan',
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFF10B981),
      trailing: IconButton(
        icon: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
        onPressed: () =>
            context.push('/therapist/laporan/add', extra: widget.patientId),
      ),
      child: _buildCatatanLaporanBody(merged),
      isEmpty: false,
      emptyMessage: '',
    );
  }

  List<Map<String, dynamic>> _getMergedEntries() {
    final List<Map<String, dynamic>> entries = [];

    for (final note in _progressNotes) {
      final n = note as Map<String, dynamic>;
      entries.add({
        'type': 'note',
        'content': n['content'] ?? '',
        'date': n['date'] ?? '',
      });
    }

    for (final report in _reports) {
      final r = report as Map<String, dynamic>;
      entries.add({
        'type': 'report',
        'title': r['title'] ?? r['summary'] ?? 'Laporan',
        'status': (r['status'] ?? '').toString().toUpperCase(),
        'date': r['session_date'] ?? r['created_at'] ?? '',
      });
    }

    entries.sort((a, b) {
      final dateA = _parseDate(a['date']);
      final dateB = _parseDate(b['date']);
      return dateB.compareTo(dateA);
    });

    return entries;
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  Widget _buildCatatanLaporanBody(List<Map<String, dynamic>> entries) {
    return Column(
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 40,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada catatan atau laporan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...entries.take(5).map((e) => _buildMergedEntryItem(e)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(
              hintText: 'Tambah catatan...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmittingNote ? null : _submitNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Simpan Catatan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'atau',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/therapist/laporan/add', extra: widget.patientId),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: Text(
              'Buat Laporan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryBlue,
              side: const BorderSide(color: AppConstants.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMergedEntryItem(Map<String, dynamic> entry) {
    final type = entry['type'];
    if (type == 'note') {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                color: Color(0xFF10B981),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['content'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(entry['date']),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // report entry
    final status = (entry['status'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['title'] ?? 'Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'SENT'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status == 'SENT' ? 'Terkirim' : 'Draft',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: status == 'SENT'
                            ? const Color(0xFF065F46)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(entry['date']),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.download_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(dateInput.toString());
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateInput.toString();
    }
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

  // ========== ARTIKULASI SECTION ==========

  Widget _buildArtikulasiSection() {
    final soundStats = _artikulasiSoundStats;
    final sessions = _artikulasiSessions;
    final recommendation =
        _artikulasiData?['evaluation']?['recommendation'] as String?;
    final summary = _artikulasiData?['summary'] as Map<String, dynamic>?;
    final totalPractice = summary?['totalPractice'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Progress Artikulasi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (totalPractice > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _needsReview > 0
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _needsReview > 0
                        ? '$totalPractice sesi • $_needsReview review'
                        : '$totalPractice sesi',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: _needsReview > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _needsReview > 0
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Sound cards
          Row(
            children: ['R', 'S', 'L', 'N']
                .map(
                  (sound) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildSoundCardCompact(
                        sound,
                        soundStats[sound] as Map<String, dynamic>?,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (recommendation != null && recommendation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Sessions grouped by game session
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 16),
            Text(
              'Rekaman Suara',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ..._buildGroupedSessions(sessions),
          ],
        ],
      ),
    );
  }

  /// Group sessions by game session (sessions within 2 minutes of each other)
  List<Widget> _buildGroupedSessions(List<dynamic> sessions) {
    final List<Widget> widgets = [];
    List<Map<String, dynamic>> currentGroup = [];

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i] as Map<String, dynamic>;
      final sessionDate = _parseDate(
        session['createdAt']?.toString() ??
            session['playedAt']?.toString() ??
            '',
      );

      if (currentGroup.isEmpty) {
        currentGroup.add(session);
      } else {
        final lastSession = currentGroup.last;
        final lastDate = _parseDate(
          lastSession['createdAt']?.toString() ??
              lastSession['playedAt']?.toString() ??
              '',
        );
        final diff = sessionDate.difference(lastDate).inMinutes;

        // Group sessions within 2 minutes as same game session
        if (diff.abs() <= 2) {
          currentGroup.add(session);
        } else {
          // Render current group and start new one
          widgets.add(_buildGameSessionCard(currentGroup));
          widgets.add(const SizedBox(height: 12));
          currentGroup = [session];
        }
      }
    }

    // Render last group
    if (currentGroup.isNotEmpty) {
      widgets.add(_buildGameSessionCard(currentGroup));
    }

    return widgets;
  }

  /// Build a game session card containing multiple rounds
  Widget _buildGameSessionCard(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return const SizedBox();

    final firstSession = sessions.first;
    final sessionDate = _parseDate(
      firstSession['createdAt']?.toString() ??
          firstSession['playedAt']?.toString() ??
          '',
    );
    final dateStr = _formatSessionDate(sessionDate);
    final totalRounds = sessions.length;

    // Count audio recordings available
    final audioCount = sessions
        .where(
          (s) => s['audioUrl'] != null && s['audioUrl'].toString().isNotEmpty,
        )
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.games_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesi Latihan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalRounds/${totalRounds} round',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                if (audioCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          size: 12,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$audioCount audio',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Sessions list
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: sessions.asMap().entries.map((entry) {
                final index = entry.key;
                final session = entry.value;
                return Column(
                  children: [
                    _buildArtikulasiSessionItem(
                      session,
                      roundNumber: index + 1,
                    ),
                    if (index < sessions.length - 1) const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Kemarin, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildArtikulasiSessionItem(
    Map<String, dynamic> session, {
    int roundNumber = 0,
  }) {
    final sessionId = session['id']?.toString() ?? '';
    final targetWord = session['targetWord']?.toString() ?? '-';
    final targetSound = session['targetSound']?.toString() ?? '-';
    final audioUrl = session['audioUrl']?.toString();
    final parentRating = session['parentRating'];
    final therapistRating = session['therapistRating'];
    final needsReview = session['needsReview'] == true;
    final createdAt =
        session['createdAt']?.toString() ?? session['playedAt']?.toString();

    final isPlaying = _currentPlayingSessionId == sessionId && _isPlayingAudio;
    final hasAudio = audioUrl != null && audioUrl.isNotEmpty;

    Color ratingColor;
    String ratingText;
    if (therapistRating == 'OKE') {
      ratingColor = const Color(0xFF10B981);
      ratingText = 'Oke';
    } else if (therapistRating == 'BELUM_OK') {
      ratingColor = const Color(0xFFEF4444);
      ratingText = 'Belum';
    } else if (needsReview) {
      ratingColor = const Color(0xFFF59E0B);
      ratingText = 'Review';
    } else if (parentRating == true) {
      ratingColor = const Color(0xFF3B82F6);
      ratingText = 'Baik';
    } else if (parentRating == false) {
      ratingColor = const Color(0xFF6B7280);
      ratingText = 'Coba Lagi';
    } else {
      ratingColor = const Color(0xFF94A3B8);
      ratingText = 'Menunggu';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Play button
          if (hasAudio)
            InkWell(
              onTap: () => _playAudio(sessionId, audioUrl!),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFF10B981)
                      : const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: isPlaying ? Colors.white : const Color(0xFF10B981),
                  size: 24,
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
          const SizedBox(width: 12),
          // Session info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      targetWord,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Bunyi "$targetSound"',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt != null ? _formatDateAgo(createdAt) : '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ratingColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ratingText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ratingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildSoundCardCompact(String sound, Map<String, dynamic>? stat) {
    final status = stat?['status'] as String? ?? 'not_started';
    final correct = stat?['correct'] as int? ?? 0;
    final total = stat?['total'] as int? ?? 0;

    Color bgColor, textColor;
    switch (status) {
      case 'mastered':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case 'improving':
      case 'practicing':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'struggling':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            sound,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$correct/$total',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status == 'not_started'
                  ? 'Belum'
                  : (status == 'mastered' ? 'Oke' : 'Latihan'),
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(String sessionId, String audioUrl) async {
    if (_currentPlayingSessionId == sessionId && _isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() {
        _isPlayingAudio = false;
        _currentPlayingSessionId = null;
      });
      return;
    }

    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlayingAudio = true;
        _currentPlayingSessionId = sessionId;
      });

      final baseUrl = ApiService().dio.options.baseUrl.replaceAll('/api', '');
      final fullUrl = audioUrl.startsWith('http')
          ? audioUrl
          : '$baseUrl$audioUrl';
      await _audioPlayer.play(UrlSource(fullUrl));

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
            _currentPlayingSessionId = null;
          });
        }
      });
    } catch (e) {
      debugPrint('Audio play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memutar audio: $e')));
        setState(() {
          _isPlayingAudio = false;
          _currentPlayingSessionId = null;
        });
      }
    }
  }

  void _showArtikulasiReviewDialog(Map<String, dynamic> session) {
    final sessionId = session['id'] as String;
    final word = session['targetWord'] ?? '';
    final sound = session['targetSound'] ?? '';
    final audioUrl = session['audioUrl'] as String?;
    final existingRating = session['therapistRating'] as String?;
    final existingScore = session['therapistScore'] as int?;
    final existingNotes = session['therapistNotes'] as String?;
    final suggestedWordsStr = session['suggestedWords'] as String?;

    String therapistRating = existingRating ?? '';
    int therapistScore = existingScore ?? 75;
    final notesController = TextEditingController(text: existingNotes ?? '');

    List<String> suggestedWords = [];
    if (suggestedWordsStr != null && suggestedWordsStr.isNotEmpty) {
      try {
        suggestedWords = List<String>.from(
          suggestedWordsStr.startsWith('[')
              ? _parseJsonArray(suggestedWordsStr)
              : [suggestedWordsStr],
        );
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Review: $word',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      'Bunyi: $sound',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Audio Player
                      if (audioUrl != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: AppConstants.primaryBlue,
                                  ),
                                  onPressed: () {
                                    final baseUrl = ApiService()
                                        .dio
                                        .options
                                        .baseUrl
                                        .replaceAll('/api', '');
                                    final fullUrl = audioUrl.startsWith('http')
                                        ? audioUrl
                                        : '$baseUrl$audioUrl';
                                    _audioPlayer.play(UrlSource(fullUrl));
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Tekan untuk mendengarkan rekaman',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Rating Buttons
                      Text(
                        'Penilaian',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setModalState(() => therapistRating = 'OKE'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: therapistRating == 'OKE'
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: therapistRating == 'OKE'
                                        ? const Color(0xFF16A34A)
                                        : const Color(
                                            0xFF16A34A,
                                          ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: therapistRating == 'OKE'
                                          ? Colors.white
                                          : const Color(0xFF16A34A),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'OKE',
                                      style: GoogleFonts.poppins(
                                        color: therapistRating == 'OKE'
                                            ? Colors.white
                                            : const Color(0xFF16A34A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Pengucapan baik',
                                      style: GoogleFonts.poppins(
                                        color: therapistRating == 'OKE'
                                            ? Colors.white70
                                            : const Color(0xFF64748B),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(
                                () => therapistRating = 'BELUM_OK',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: therapistRating == 'BELUM_OK'
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: therapistRating == 'BELUM_OK'
                                        ? const Color(0xFFDC2626)
                                        : const Color(
                                            0xFFDC2626,
                                          ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      color: therapistRating == 'BELUM_OK'
                                          ? Colors.white
                                          : const Color(0xFFDC2626),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'BELUM OK',
                                      style: GoogleFonts.poppins(
                                        color: therapistRating == 'BELUM_OK'
                                            ? Colors.white
                                            : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Perlu latihan lagi',
                                      style: GoogleFonts.poppins(
                                        color: therapistRating == 'BELUM_OK'
                                            ? Colors.white70
                                            : const Color(0xFF64748B),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Score Slider
                      Text(
                        'Skor: $therapistScore/100',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: therapistScore.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: AppConstants.primaryBlue,
                        onChanged: (value) =>
                            setModalState(() => therapistScore = value.toInt()),
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      Text(
                        'Catatan / Feedback',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Berikan catatan untuk orang tua...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Suggested Words
                      if (suggestedWords.isNotEmpty) ...[
                        Text(
                          'Kata Latihan yang Disarankan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: suggestedWords
                              .map(
                                (w) => Chip(
                                  label: Text(w),
                                  backgroundColor: const Color(0xFFDBEAFE),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: therapistRating.isEmpty
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await _submitArtikulasiReview(
                                    sessionId: sessionId,
                                    rating: therapistRating,
                                    score: therapistScore,
                                    notes: notesController.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan Review',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseJsonArray(String jsonStr) {
    try {
      final trimmed = jsonStr.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        final inner = trimmed.substring(1, trimmed.length - 1);
        return inner
            .split(',')
            .map((s) => s.trim().replaceAll('"', ''))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _submitArtikulasiReview({
    required String sessionId,
    required String rating,
    required int score,
    String? notes,
  }) async {
    try {
      final response = await _apiService.reviewArtikulasiSession(
        sessionId: sessionId,
        therapistRating: rating,
        therapistScore: score,
        therapistNotes: notes,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rating == 'OKE'
                  ? '✓ Review berhasil. Notifikasi dikirim ke orang tua.'
                  : '✓ Review disimpan. Orang tua akan mendapat notifikasi.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _fetchPatientData();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan review');
      }
    } catch (e) {
      debugPrint('Submit review error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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
