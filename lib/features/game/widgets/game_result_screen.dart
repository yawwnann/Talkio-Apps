import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_log_provider.dart';
import '../../../core/constants/app_constants.dart';

/// GameResultScreen
/// Layar hasil yang dipakai bersama semua game.
/// Menampilkan skor, emoji berdasarkan performa, tombol "Main Lagi" dan "Kembali ke Menu".
/// Auto-manggil logGame() sebelum layar ditampilkan.
class GameResultScreen extends ConsumerStatefulWidget {
  final String gameName;
  final int score;
  final int maxScore;
  final int durationSeconds;
  final String childId;
  final String gameType;
  final VoidCallback? onMainLagi;
  final VoidCallback? onKembaliMenu;

  const GameResultScreen({
    super.key,
    required this.gameName,
    required this.score,
    required this.maxScore,
    required this.durationSeconds,
    required this.childId,
    required this.gameType,
    this.onMainLagi,
    this.onKembaliMenu,
  });

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
    _logResult();
  }

  Future<void> _logResult() async {
    if (_logged || widget.childId.isEmpty) return;
    _logged = true;
    await ref.read(gameLogProvider.notifier).logGame(
          childId: widget.childId,
          gameScore: widget.score,
          duration: widget.durationSeconds,
          gameType: widget.gameType,
        );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _emoji {
    final percent = widget.maxScore > 0
        ? (widget.score / widget.maxScore * 100).round()
        : 0;
    if (percent >= 80) return '🎉';
    if (percent >= 50) return '😊';
    return '💪';
  }

  String get _title {
    final percent = widget.maxScore > 0
        ? (widget.score / widget.maxScore * 100).round()
        : 0;
    if (percent >= 80) return 'Luar Biasa!';
    if (percent >= 50) return 'Bagus Sekali!';
    return 'Semangat!';
  }

  Color get _bgColor {
    final percent = widget.maxScore > 0
        ? (widget.score / widget.maxScore * 100).round()
        : 0;
    if (percent >= 80) return AppConstants.successGreen.withValues(alpha: 0.1);
    if (percent >= 50) return const Color(0xFFFEF3C7);
    return const Color(0xFFFEE2E2);
  }

  Color get _accentColor {
    final percent = widget.maxScore > 0
        ? (widget.score / widget.maxScore * 100).round()
        : 0;
    if (percent >= 80) return AppConstants.successGreen;
    if (percent >= 50) return const Color(0xFFD97706);
    return AppConstants.errorRed;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) return '$minutes menit $secs detik';
    return '$secs detik';
  }

  @override
  Widget build(BuildContext context) {
    final percent = widget.maxScore > 0
        ? (widget.score / widget.maxScore * 100).round()
        : 0;

    return Scaffold(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji besar
                    Text(
                      _emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),

                    // Judul
                    Text(
                      _title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      widget.gameName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppConstants.textGray,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Skor Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SKOR',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textGray,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.score}',
                            style: GoogleFonts.poppins(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _accentColor,
                            ),
                          ),
                          Text(
                            'dari ${widget.maxScore}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppConstants.textGray,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.maxScore > 0
                                  ? widget.score / widget.maxScore
                                  : 0,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation(_accentColor),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$percent%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Durasi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: AppConstants.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Waktu: ${_formatDuration(widget.durationSeconds)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppConstants.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tombol
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: widget.onMainLagi,
                        icon: const Icon(Icons.replay, color: Colors.white),
                        label: Text(
                          'Main Lagi',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: widget.onKembaliMenu ??
                            () => Navigator.of(context).popUntil((r) => r.isFirst),
                        child: Text(
                          'Kembali ke Menu',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppConstants.textGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}