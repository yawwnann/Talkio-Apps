import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// Voice Practice Simple Page
/// Halaman latihan suara tanpa recording (untuk testing)
class VoicePracticeSimplePage extends ConsumerStatefulWidget {
  const VoicePracticeSimplePage({super.key});

  @override
  ConsumerState<VoicePracticeSimplePage> createState() => _VoicePracticeSimplePageState();
}

class _VoicePracticeSimplePageState extends ConsumerState<VoicePracticeSimplePage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isRecording = false;
  bool _hasRecorded = false;
  int _currentWordIndex = 0;
  int _score = 0;
  
  final List<Map<String, dynamic>> _practiceWords = [
    {
      'word': 'MAMA',
      'description': 'Ucapkan "MAMA" dengan jelas',
      'tips': 'Bibir rapat, lalu buka dengan suara "MA"',
    },
    {
      'word': 'PAPA',
      'description': 'Ucapkan "PAPA" dengan jelas',
      'tips': 'Bibir rapat, lalu lepas dengan suara "PA"',
    },
    {
      'word': 'MINUM',
      'description': 'Ucapkan "MINUM" dengan jelas',
      'tips': 'MI-NUM, pisahkan suku kata',
    },
    {
      'word': 'MAKAN',
      'description': 'Ucapkan "MAKAN" dengan jelas',
      'tips': 'MA-KAN, tekan huruf K',
    },
    {
      'word': 'TERIMA KASIH',
      'description': 'Ucapkan "TERIMA KASIH" dengan jelas',
      'tips': 'TE-RI-MA KA-SIH, pelan-pelan',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _simulateRecording() async {
    setState(() {
      _isRecording = true;
    });
    _pulseController.repeat(reverse: true);
    
    // Simulate recording for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
    _pulseController.stop();
    _pulseController.reset();
    
    _showRecordingResult();
  }

  void _showRecordingResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Rekaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text('Rekaman berhasil!'),
            const SizedBox(height: 8),
            Text('Kata: ${_practiceWords[_currentWordIndex]['word']}'),
            const SizedBox(height: 8),
            const Text(
              '(Mode Demo - Audio recording dinonaktifkan)',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _simulatePlayback();
            },
            child: const Text('Putar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextWord();
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }

  void _simulatePlayback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔊 Memutar rekaman... (Mode Demo)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _nextWord() {
    setState(() {
      _score += 20; // Add score
      _hasRecorded = false;
      if (_currentWordIndex < _practiceWords.length - 1) {
        _currentWordIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Selamat!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text('Kamu telah menyelesaikan semua latihan!'),
            const SizedBox(height: 8),
            Text('Skor: $_score/100'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Main Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _currentWordIndex = 0;
      _score = 0;
      _hasRecorded = false;
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentWord = _practiceWords[_currentWordIndex];

    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Latihan Suara (Demo)',
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Skor: $_score',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo Mode Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode Demo: Audio recording dinonaktifkan untuk testing',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress
            LinearProgressIndicator(
              value: (_currentWordIndex + 1) / _practiceWords.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Kata ${_currentWordIndex + 1} dari ${_practiceWords.length}',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Word Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      currentWord['word'],
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      currentWord['description'],
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentWord['tips'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recording Button
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: _isRecording ? null : _simulateRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : theme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : theme.primaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
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
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isRecording ? 'Merekam... (Demo)' : 'Tap untuk merekam',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (_hasRecorded) ...[
              CustomButton(
                text: 'Putar Rekaman (Demo)',
                onPressed: _simulatePlayback,
                icon: Icons.play_arrow,
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: 'Lanjut ke Kata Berikutnya',
                onPressed: _nextWord,
                icon: Icons.arrow_forward,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Bermain (Mode Demo):',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Baca kata yang ditampilkan'),
                    const Text('2. Perhatikan tips pengucapan'),
                    const Text('3. Tekan tombol mikrofon untuk simulasi rekam'),
                    const Text('4. Ucapkan kata dengan jelas (simulasi)'),
                    const Text('5. Tunggu 3 detik untuk simulasi selesai'),
                    const Text('6. Lanjut ke kata berikutnya'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}