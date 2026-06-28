import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../data/latihan_artikulasi_data.dart';
import '../widgets/game_result_screen.dart';
import '../widgets/round_progress_bar.dart';

/// LatihanArtikulasiPage
/// Game: latih pengucapan kata sulit (R, S, L, N) untuk anak 3-5 tahun.
/// Orang tua membimbing, anak mencoba rekam + playback.
/// Real recording + upload ke backend + forward chaining hints.
class LatihanArtikulasiPage extends ConsumerStatefulWidget {
  final String childId;
  final int totalRounds;
  final String? targetSound; // 'R', 'S', 'L', 'N' atau null = acak

  const LatihanArtikulasiPage({
    super.key,
    required this.childId,
    this.totalRounds = 6,
    this.targetSound,
  });

  @override
  ConsumerState<LatihanArtikulasiPage> createState() => _LatihanArtikulasiPageState();
}

class _LatihanArtikulasiPageState extends ConsumerState<LatihanArtikulasiPage>
    with TickerProviderStateMixin {
  late List<Map<String, String>> _rounds;
  int _currentRound = 0;
  int _correctCount = 0;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  // Recording state
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _recordedFilePath;
  String? _uploadedAudioUrl; // URL dari backend
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isUploading = false;
  bool? _liked; // null = belum dinilai, true = 👍, false = 👎
  String? _fcHint; // hints dari forward chaining
  bool _isPlaying = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Get rounds by target or random
    if (widget.targetSound != null &&
        LatihanArtikulasiData.targets.contains(widget.targetSound)) {
      _rounds = LatihanArtikulasiData.getRoundsByTarget(
        widget.totalRounds,
        widget.targetSound!
      );
    } else {
      _rounds = LatihanArtikulasiData.getRounds(widget.totalRounds);
    }

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  /// Check microphone permission
  Future<bool> _checkPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izinkan akses mikrofon untuk merekam suara'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }
    return true;
  }

  /// Start real recording
  Future<void> _startRecording() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    try {
      // Stop any playback
      await _player.stop();

      setState(() {
        _isRecording = true;
        _hasRecorded = false;
        _liked = null;
        _fcHint = null;
      });

      _pulseController.repeat(reverse: true);

      // Start recording to temporary file
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'articulation_$timestamp.m4a';
      _recordedFilePath = '${tempDir.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordedFilePath!,
      );

      // Auto-stop after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      await _stopRecording();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal merekam: $e')),
        );
      }
      setState(() => _isRecording = false);
    }
  }

  /// Stop recording and prepare for playback
  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        _recordedFilePath = path;

        // Debug: Check file exists and size
        final file = File(path);
        if (await file.exists()) {
          final stat = await file.stat();
          debugPrint('[Artikulasi] Recording saved: $path (${stat.size} bytes)');
        } else {
          debugPrint('[Artikulasi] WARNING: File not found at path: $path');
        }

        setState(() {
          _isRecording = false;
          _hasRecorded = true;
        });
        _pulseController.stop();
        _pulseController.reset();

        // Auto-playback preview
        setState(() => _isPlaying = true);
        await _player.play(DeviceFileSource(path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghentikan rekaman: $e')),
        );
      }
    }
  }

  /// Putar audio (local setelah rekam, atau URL dari backend)
  Future<void> _playbackAudio() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }

    if (_uploadedAudioUrl != null) {
      try {
        setState(() => _isPlaying = true);
        await _player.play(UrlSource(_uploadedAudioUrl!));
        return;
      } catch (e) {
        debugPrint('URL play error: $e');
        setState(() => _isPlaying = false);
      }
    }
    if (_recordedFilePath != null) {
      try {
        setState(() => _isPlaying = true);
        await _player.play(DeviceFileSource(_recordedFilePath!));
        return;
      } catch (e) {
        debugPrint('Local play error: $e');
        setState(() => _isPlaying = false);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio tidak tersedia')),
      );
    }
  }

  /// Submit sesi + forward ke next round atau finish
  Future<void> _submitAndNext() async {
    setState(() => _isUploading = true);

    // Auto-score: setiap ronde yang berhasil direkam dapat poin
    _correctCount++;
    _score += LatihanArtikulasiData.scorePerRound;

    try {
      // Pakai ApiService (sudah ada di project)
      final apiService = ApiService();

      // Prepare audio file
      File? audioFile;
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          final stat = await file.stat();
          debugPrint('[Artikulasi] Submitting audio: $_recordedFilePath (${stat.size} bytes)');
          audioFile = file;
        } else {
          debugPrint('[Artikulasi] WARNING: Audio file not found: $_recordedFilePath');
        }
      }

      // Kirim ke backend via ApiService
      final response = await apiService.logArtikulasiSession(
        childId: widget.childId,
        targetWord: _rounds[_currentRound]['word']!,
        targetSound: _rounds[_currentRound]['target']!,
        parentRating: true,
        parentNotes: null,
        audioFile: audioFile,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
        final innerData = dataMap['data'] is Map<String, dynamic>
            ? dataMap['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        // Ambil audioUrl dari session backend
        final sessionData = innerData['session'] is Map<String, dynamic>
            ? innerData['session'] as Map<String, dynamic>
            : <String, dynamic>{};
        final audioUrl = sessionData['audioUrl'] as String?;
        if (audioUrl != null) {
          setState(() {
            _uploadedAudioUrl = audioUrl;
          });
        }

        // Ambil hints
        final hints = innerData['hints'] as List?;
        if (hints != null && hints.isNotEmpty) {
          setState(() {
            _fcHint = hints.first.toString();
          });
        }

        // Tampilkan recommendation
        final recommendation = innerData['nextRecommendation'] as String?;
        if (recommendation != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💡 $recommendation'),
              backgroundColor: AppConstants.primaryBlue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Artikulasi upload error: $e');
      // Lanjut tanpa halt walau error
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }

    // Lanjut round atau selesai
    if (_currentRound + 1 >= _rounds.length) {
      _showResult();
    } else {
      _nextRound();
    }
  }

  void _nextRound() {
    setState(() {
      _currentRound++;
      _isRecording = false;
      _hasRecorded = false;
      _liked = null;
      _fcHint = null;
      _recordedFilePath = null;
      _uploadedAudioUrl = null;
    });
  }

  void _showResult() {
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          gameName: LatihanArtikulasiData.gameType,
          score: _score,
          maxScore: LatihanArtikulasiData.scorePerRound * _rounds.length,
          durationSeconds: elapsed,
          childId: widget.childId,
          gameType: LatihanArtikulasiData.gameType,
          hideScore: true,
          completionMessage: 'Latihan berhasil diselesaikan. Hasil latihan telah dikirim dan akan dievaluasi oleh terapis untuk memantau perkembangan artikulasi anak.',
          onMainLagi: () {
            Navigator.of(context).pop();
            setState(() {
              _currentRound = 0;
              _correctCount = 0;
              _score = 0;
              _startTime = DateTime.now();
              _isRecording = false;
              _hasRecorded = false;
              _liked = false;
              _fcHint = null;
              _recordedFilePath = null;
            });
            _rounds = LatihanArtikulasiData.getRounds(widget.totalRounds);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_currentRound];

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Latihan Artikulasi',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF0F7FF),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress
              RoundProgressBar(
                currentRound: _currentRound + 1,
                totalRounds: _rounds.length,
              ),
              const SizedBox(height: 20),

              // Target bunyi badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🎯 Target: ${_getSoundLabel(round['target']!)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kata besar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      round['emoji']!,
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      round['word']!,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E40AF),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tips dari orang tua
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        round['tip']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FC Hint (if any)
              if (_fcHint != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fcHint!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Recording section
              _buildRecordingSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    if (!_hasRecorded) {
      // Not recorded yet - show record button
      return Column(
        children: [
          Text(
            'Orang tua bimbing anak mengucapkan kata ini dengan benar!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppConstants.textGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Record button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _isRecording ? null : _startRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : AppConstants.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : AppConstants.primaryBlue)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _isRecording
                ? 'Merekam... (3 detik)'
                : 'Tekan untuk merekam suara anak',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppConstants.textGray,
            ),
          ),
        ],
      );
    } else {
      // Has recorded - show playback options
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                const SizedBox(width: 8),
                Text(
                  'Rekaman tersimpan! 🎤',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppConstants.textGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Playback button
            OutlinedButton.icon(
              onPressed: _playbackAudio,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? 'Berhenti' : 'Dengarkan ulang'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isPlaying ? Colors.red : AppConstants.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitAndNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isUploading
                      ? 'Menyimpan...'
                      : _currentRound + 1 >= _rounds.length
                          ? 'Lihat Hasil'
                          : 'Simpan & Lanjut',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getSoundLabel(String target) {
    const labels = {
      'R': 'Bunyi R — Gulungkan lidah!',
      'S': 'Bunyi S — Ujung lidah atas!',
      'L': 'Bunyi L — Ujung lidah ke atas!',
      'N': 'Bunyi N — Dari hidung!',
    };
    return labels[target] ?? 'Bunyi $target';
  }
}