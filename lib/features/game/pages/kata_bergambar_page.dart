import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../data/kata_bergambar_data.dart';
import '../widgets/game_result_screen.dart';
import '../widgets/choice_card.dart';
import '../widgets/round_progress_bar.dart';

/// KataBergambarPage
/// Game: lihat gambar (emoji) → pilih label teks yang benar.
class KataBergambarPage extends ConsumerStatefulWidget {
  final String childId;
  final int choicesCount;
  final int totalRounds;
  final String hintMode; // 'highlight' or 'none'

  const KataBergambarPage({
    super.key,
    required this.childId,
    this.choicesCount = 3,
    this.totalRounds = 8,
    this.hintMode = 'none',
  });

  @override
  ConsumerState<KataBergambarPage> createState() => _KataBergambarPageState();
}

class _KataBergambarPageState extends ConsumerState<KataBergambarPage>
    with SingleTickerProviderStateMixin {
  late List<Map<String, String>> _rounds;
  int _currentRound = 0;
  int _correctCount = 0;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  late List<Map<String, String>> _choices;
  Map<String, String>? _selectedChoice;
  bool? _isCorrect;
  bool _answered = false;
  bool _hintShown = false;

  // Hint animation
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _rounds = KataBergambarData.getRounds(widget.totalRounds);
    _buildChoices();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  void _buildChoices() {
    final correct = _rounds[_currentRound];
    _choices = KataBergambarData.generateChoices(correct, widget.choicesCount);
    _selectedChoice = null;
    _isCorrect = null;
    _answered = false;
    _hintShown = false;
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
        _score += KataBergambarData.scorePerRound;
      } else if (widget.hintMode == 'highlight' && !_hintShown) {
        // Show hint: highlight correct answer
        _hintShown = true;
        _bounceController.forward().then((_) => _bounceController.reverse());
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
          gameName: KataBergambarData.gameType,
          score: _score,
          maxScore: KataBergambarData.scorePerRound * widget.totalRounds,
          durationSeconds: elapsed,
          childId: widget.childId,
          gameType: KataBergambarData.gameType,
          onMainLagi: () {
            Navigator.of(context).pop();
            setState(() {
              _currentRound = 0;
              _correctCount = 0;
              _score = 0;
              _startTime = DateTime.now();
            });
            _rounds = KataBergambarData.getRounds(widget.totalRounds);
            _buildChoices();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_currentRound];
    final correct = round;

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Kata Bergambar',
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⭐ $_score',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
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

              // Gambar besar (emoji)
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _hintShown ? _bounceAnimation.value : 1.0,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _hintShown
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _hintShown
                              ? const Color(0xFF16A34A)
                              : AppConstants.primaryBlue.withValues(alpha: 0.3),
                          width: _hintShown ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryBlue.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          round['emoji']!,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Kategori badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  KataBergambarData.categoryLabel(round['category']!),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppConstants.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instruksi
              Text(
                'Apa nama benda ini?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol pilihan teks
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _choices.map((choice) {
                  final isSelected = _selectedChoice == choice;
                  final isCorrectAnswer = choice['id'] == correct['id'];

                  // Highlight hint: show correct label differently after wrong answer
                  final isHinted = _hintShown && isCorrectAnswer;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: ElevatedButton(
                        onPressed: _answered ? null : () => _selectChoice(choice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHinted
                              ? const Color(0xFFDCFCE7)
                              : isSelected
                                  ? (_isCorrect == true
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2))
                                  : Colors.white,
                          foregroundColor: isHinted
                              ? const Color(0xFF16A34A)
                              : isSelected
                                  ? (_isCorrect == true
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626))
                                  : AppConstants.textDark,
                          elevation: isHinted ? 4 : 1,
                          side: BorderSide(
                            color: isHinted
                                ? const Color(0xFF16A34A)
                                : isSelected
                                    ? (_isCorrect == true
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626))
                                    : AppConstants.borderColor,
                            width: isHinted ? 2 : 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isHinted) ...[
                              const Icon(Icons.lightbulb, size: 16, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                choice['word']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                              ? 'Benar! ✨'
                              : _hintShown
                                  ? 'Petunjuk: "${correct['word']}" ${correct['emoji']}'
                                  : 'Belum tepat. Yang benar "${correct['word']}" ${correct['emoji']}',
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