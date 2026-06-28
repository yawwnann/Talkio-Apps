import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../data/tebak_suara_data.dart';
import '../widgets/game_result_screen.dart';
import '../widgets/choice_card.dart';
import '../widgets/round_progress_bar.dart';

/// TebakSuaraPage
/// Game: dengarkan suara lingkungan → pilih gambar yang sesuai.
class TebakSuaraPage extends ConsumerStatefulWidget {
  final String childId;
  final int totalRounds;

  const TebakSuaraPage({
    super.key,
    required this.childId,
    this.totalRounds = 8,
  });

  @override
  ConsumerState<TebakSuaraPage> createState() => _TebakSuaraPageState();
}

class _TebakSuaraPageState extends ConsumerState<TebakSuaraPage>
    with TickerProviderStateMixin {
  late List<Map<String, String>> _rounds;
  int _currentRound = 0;
  int _correctCount = 0;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  late List<Map<String, String>> _choices;
  Map<String, String>? _selectedChoice;
  bool? _isCorrect;
  bool _answered = false;
  bool _isPlaying = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _rounds = TebakSuaraData.getRounds(widget.totalRounds);
    _buildChoices();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Listen for audio completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _waveController.stop();
      }
    });
  }

  void _buildChoices() {
    final correct = _rounds[_currentRound];
    // Tebak Suara: selalu 3 pilihan
    _choices = TebakSuaraData.generateChoices(correct, 3);
    _selectedChoice = null;
    _isCorrect = null;
    _answered = false;
  }

  Future<void> _playSound() async {
    if (_isPlaying) return;

    final currentItem = _rounds[_currentRound];
    final itemId = currentItem['id']!;
    final itemName = currentItem['name']!;

    // Stop any currently playing audio first
    await _audioPlayer.stop();

    setState(() => _isPlaying = true);
    _waveController.repeat();

    try {
      // Play the actual audio file
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setSource(AssetSource('sounds/$itemId.mp3'));
      await _audioPlayer.resume();
      debugPrint('[TebakSuara] Playing: sounds/$itemId.mp3');
    } catch (e) {
      debugPrint('[TebakSuara] Error playing sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar suara $itemName'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isPlaying = false);
      _waveController.stop();
    }
  }

  void _selectChoice(Map<String, String> choice) {
    if (_answered) return;
    final correct = _rounds[_currentRound];
    final isRight = choice['id'] == correct['id'];

    setState(() {
      _selectedChoice = choice;
      _isCorrect = isRight;
      _answered = true;
      if (isRight) {
        _correctCount++;
        _score += TebakSuaraData.scorePerRound;
      }
    });
  }

  void _nextRound() {
    if (_currentRound + 1 >= widget.totalRounds) {
      _showResult();
      return;
    }
    setState(() {
      _currentRound++;
    });
    _buildChoices();
  }

  void _showResult() {
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          gameName: TebakSuaraData.gameType,
          score: _score,
          maxScore: TebakSuaraData.scorePerRound * widget.totalRounds,
          durationSeconds: elapsed,
          childId: widget.childId,
          gameType: TebakSuaraData.gameType,
          onMainLagi: () {
            Navigator.of(context).pop();
            setState(() {
              _currentRound = 0;
              _correctCount = 0;
              _score = 0;
              _startTime = DateTime.now();
            });
            _rounds = TebakSuaraData.getRounds(widget.totalRounds);
            _buildChoices();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_currentRound];
    final correct = round;

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Tebak Suara',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryBlue.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              RoundProgressBar(
                currentRound: _currentRound + 1,
                totalRounds: widget.totalRounds,
              ),
              const SizedBox(height: 20),

              Text(
                'Dengarkan suara di sekitarmu, lalu pilih yang benar!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppConstants.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Tombol dengarkan
              GestureDetector(
                onTap: _isPlaying ? null : _playSound,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPlaying
                          ? [Colors.teal, Colors.teal.shade700]
                          : [AppConstants.primaryBlue, AppConstants.lightBlue],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying ? Colors.teal : AppConstants.primaryBlue)
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isPlaying)
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, _) {
                            return SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: _WavePainter(
                                  progress: _waveController.value,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      Icon(
                        _isPlaying ? Icons.hearing : Icons.volume_up,
                        size: 64,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isPlaying ? 'Memutar...' : 'Tekan untuk dengarkan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppConstants.textGray,
                ),
              ),
              const SizedBox(height: 20),

              // Kategori badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kategori: ${TebakSuaraData.categoryLabel(round['category']!)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kartu pilihan
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _choices.length,
                itemBuilder: (context, index) {
                  final choice = _choices[index];
                  final isCorrectAnswer = choice['id'] == correct['id'];

                  return ChoiceCard(
                    emoji: choice['emoji']!,
                    label: choice['name']!,
                    isSelected: _selectedChoice == choice,
                    isCorrect: _answered
                        ? (isCorrectAnswer ? true : (_selectedChoice == choice ? false : null))
                        : null,
                    onTap: () => _selectChoice(choice),
                    size: 60,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Feedback
              if (_answered) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect == true
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect == true ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect == true
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _isCorrect == true
                              ? 'Benar! 🎉'
                              : 'Yang benar "${correct['name']}" ${correct['emoji']}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isCorrect == true
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentRound + 1 >= widget.totalRounds ? 'Lihat Hasil' : 'Ronde Berikutnya',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple wave painter for audio visual feedback
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final minRadius = maxRadius * 0.5;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = minRadius + (maxRadius - minRadius) * phase;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress || old.color != color;
}