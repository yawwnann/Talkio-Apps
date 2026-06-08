import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../data/suara_binatang_data.dart';
import '../widgets/game_result_screen.dart';
import '../widgets/choice_card.dart';
import '../widgets/round_progress_bar.dart';

/// SuaraBinatangPage
/// Game: dengarkan suara hewan → pilih kartu yang benar.
class SuaraBinatangPage extends ConsumerStatefulWidget {
  final String childId;
  final int choicesCount;
  final int totalRounds;

  const SuaraBinatangPage({
    super.key,
    required this.childId,
    this.choicesCount = 2,
    this.totalRounds = 5,
  });

  @override
  ConsumerState<SuaraBinatangPage> createState() => _SuaraBinatangPageState();
}

class _SuaraBinatangPageState extends ConsumerState<SuaraBinatangPage>
    with TickerProviderStateMixin {
  // Game state
  late List<Map<String, String>> _rounds;
  int _currentRound = 0;
  int _correctCount = 0;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  // Round state
  late List<Map<String, String>> _choices;
  Map<String, String>? _selectedChoice;
  bool? _isCorrect;
  bool _answered = false;
  bool _isPlaying = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rounds = SuaraBinatangData.getRounds(widget.totalRounds);
    _buildChoices();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for audio completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  void _buildChoices() {
    final correct = _rounds[_currentRound];
    _choices = SuaraBinatangData.generateChoices(correct, widget.choicesCount);
    _selectedChoice = null;
    _isCorrect = null;
    _answered = false;
  }

  Future<void> _playSound() async {
    if (_isPlaying) return;

    final currentAnimal = _rounds[_currentRound];
    final animalId = currentAnimal['id']!;
    final animalName = currentAnimal['name']!;

    // Stop any currently playing audio first
    await _audioPlayer.stop();

    setState(() => _isPlaying = true);
    _pulseController.repeat(reverse: true);

    try {
      // Play the actual audio file
      // Use ReleaseMode.release to avoid audio issues
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setSource(AssetSource('sounds/$animalId.mp3'));
      await _audioPlayer.resume();
      debugPrint('[SuaraBinatang] Playing: sounds/$animalId.mp3');
    } catch (e) {
      debugPrint('[SuaraBinatang] Error playing sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar suara $animalName'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isPlaying = false);
      _pulseController.stop();
      _pulseController.reset();
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
        _score += SuaraBinatangData.scorePerRound;
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          gameName: SuaraBinatangData.gameType,
          score: _score,
          maxScore: SuaraBinatangData.scorePerRound * widget.totalRounds,
          durationSeconds: elapsed,
          childId: widget.childId,
          gameType: SuaraBinatangData.gameType,
          onMainLagi: () {
            Navigator.of(context).pop();
            setState(() {
              _currentRound = 0;
              _correctCount = 0;
              _score = 0;
              _startTime = DateTime.now();
            });
            _rounds = SuaraBinatangData.getRounds(widget.totalRounds);
            _buildChoices();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final round = _rounds[_currentRound];
    final correct = round;

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Suara Binatang',
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
              // Progress
              RoundProgressBar(
                currentRound: _currentRound + 1,
                totalRounds: widget.totalRounds,
              ),
              const SizedBox(height: 24),

              // Instruksi
              Text(
                'Dengarkan suara-hewan, lalu pilih yang benar!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppConstants.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Tombol putar suara
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _isPlaying ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: _isPlaying ? null : _playSound,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isPlaying
                                ? [Colors.orange, Colors.deepOrange]
                                : [AppConstants.primaryBlue, AppConstants.lightBlue],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isPlaying
                                      ? Colors.orange
                                      : AppConstants.primaryBlue)
                                  .withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.volume_up : Icons.play_arrow_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                _isPlaying ? 'Memutar...' : 'Tekan untuk dengarkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppConstants.textGray,
                ),
              ),
              const SizedBox(height: 28),

              // Petunjuk hewan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Suara hewan apa yang baru kamu dengar?',
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
              const SizedBox(height: 20),

              // Kartu pilihan
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.choicesCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _choices.length,
                itemBuilder: (context, index) {
                  final choice = _choices[index];
                  final isSelected = _selectedChoice == choice;
                  final isCorrectAnswer = choice['id'] == correct['id'];

                  return ChoiceCard(
                    emoji: choice['emoji']!,
                    label: choice['name']!,
                    isSelected: isSelected,
                    isCorrect: _answered
                        ? (isCorrectAnswer ? true : (isSelected ? false : null))
                        : null,
                    onTap: () => _selectChoice(choice),
                    size: 70,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Feedback + tombol lanjut
              if (_answered) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                              : 'Belum tepat. Yang benar "${correct['name']}" ${correct['emoji']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
                      _currentRound + 1 >= widget.totalRounds
                          ? 'Lihat Hasil'
                          : 'Ronde Berikutnya',
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
