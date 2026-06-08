import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../data/cerita_interaktif_data.dart';
import '../widgets/game_result_screen.dart';

/// CeritaInteraktifPage
/// Game: baca cerita singkat → pilih alur → story branching.
/// Untuk anak 18-60 bulan.
class CeritaInteraktifPage extends ConsumerStatefulWidget {
  final String childId;
  final int storyIndex; // 0, 1, 2 = pilih cerita

  const CeritaInteraktifPage({
    super.key,
    required this.childId,
    this.storyIndex = 0,
  });

  @override
  ConsumerState<CeritaInteraktifPage> createState() => _CeritaInteraktifPageState();
}

class _CeritaInteraktifPageState extends ConsumerState<CeritaInteraktifPage>
    with TickerProviderStateMixin {
  late Map<String, dynamic> _story;
  int _currentPage = 0;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Default ke cerita pertama jika index tidak valid
    _story = CeritaInteraktifData.getStory(widget.storyIndex) ??
             CeritaInteraktifData.stories[0];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  void _selectChoice(Map<String, dynamic> choice) {
    final next = choice['next'] as int;
    _score += CeritaInteraktifData.scorePerRound;

    _fadeController.reverse().then((_) {
      setState(() => _currentPage = next);
      _fadeController.forward();
    });
  }

  void _showResult() {
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          gameName: CeritaInteraktifData.gameType,
          score: _score,
          maxScore: _countTotalPages() * CeritaInteraktifData.scorePerRound,
          durationSeconds: elapsed,
          childId: widget.childId,
          gameType: CeritaInteraktifData.gameType,
          onMainLagi: () {
            Navigator.of(context).pop();
            setState(() {
              _currentPage = 0;
              _score = 0;
              _startTime = DateTime.now();
            });
            _fadeController.forward();
          },
        ),
      ),
    );
  }

  int _countTotalPages() {
    final pages = _story['pages'] as List;
    return pages.length;
  }

  void _goHome() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _story['pages'] as List<Map<String, dynamic>>;
    final currentPageData = pages[_currentPage];
    final choices = currentPageData['choices'] as List;
    final isLastPage = choices.isEmpty;
    final totalPages = pages.length;

    return Scaffold(
      appBar: SimpleAppBar(
        title: _story['title'] ?? 'Cerita Interaktif',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF8F0),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Story emoji + title
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _story['emoji'] ?? '📖',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _story['title'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Cerita $_currentPage / ${totalPages - 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppConstants.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _currentPage / (totalPages - 1).clamp(1, 100),
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFD97706)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ilustrasi (emoji besar)
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _getPageEmoji(_currentPage),
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Teks cerita
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentPageData['text'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF1E293B),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isLastPage) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '✨ TAMAT ✨',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pilihan
                  if (!isLastPage) ...[
                    Text(
                      'Apa yang terjadi selanjutnya?',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppConstants.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...choices.map((choice) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _selectChoice(choice),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E293B),
                            elevation: 1,
                            side: BorderSide(color: AppConstants.borderColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  choice['label'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: AppConstants.textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ] else ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _showResult,
                        icon: const Icon(Icons.emoji_events, color: Colors.white),
                        label: Text(
                          'Lihat Hasil Ceritamu! 🎉',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
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
                        onPressed: _goHome,
                        child: Text(
                          'Pilih Cerita Lain',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppConstants.textGray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPageEmoji(int pageIndex) {
    // Simple emoji mapping based on page
    const emojiMap = ['🤔', '🍽️', '😋', '😴', '🎉', '🌳', '⚽', '👦', '😊', '🩺', '🤒', '💊', '🌟'];
    return emojiMap[pageIndex % emojiMap.length];
  }
}