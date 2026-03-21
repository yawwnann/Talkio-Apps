import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// Konsultasi Page
/// Halaman konsultasi dengan terapis
class KonsultasiPage extends ConsumerStatefulWidget {
  const KonsultasiPage({super.key});

  @override
  ConsumerState<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends ConsumerState<KonsultasiPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _childAgeController = TextEditingController();
  final _concernsController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  
  // Assessment data
  final Map<String, dynamic> _assessmentData = {};
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Apakah anak Anda sudah bisa mengucapkan kata pertama?',
      'options': ['Ya', 'Tidak', 'Tidak yakin'],
      'key': 'first_word',
    },
    {
      'question': 'Berapa banyak kata yang bisa diucapkan anak Anda?',
      'options': ['Kurang dari 10', '10-50', 'Lebih dari 50'],
      'key': 'vocabulary_count',
    },
    {
      'question': 'Apakah anak Anda bisa membuat kalimat sederhana?',
      'options': ['Ya', 'Tidak', 'Kadang-kadang'],
      'key': 'simple_sentences',
    },
    {
      'question': 'Apakah orang lain bisa memahami ucapan anak Anda?',
      'options': ['Selalu', 'Kadang-kadang', 'Jarang'],
      'key': 'speech_clarity',
    },
    {
      'question': 'Apakah anak Anda merespons ketika dipanggil namanya?',
      'options': ['Selalu', 'Kadang-kadang', 'Jarang'],
      'key': 'name_response',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _childAgeController.dispose();
    _concernsController.dispose();
    _symptomsController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitConsultation() {
    // Process consultation data
    final consultationData = {
      'child_age': _childAgeController.text,
      'concerns': _concernsController.text,
      'symptoms': _symptomsController.text,
      'additional_info': _additionalInfoController.text,
      'assessment': _assessmentData,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Show result
    _showConsultationResult(consultationData);
  }

  void _showConsultationResult(Map<String, dynamic> data) {
    // Simple assessment logic
    int score = 0;
    
    if (_assessmentData['first_word'] == 'Ya') {
      score += 20;
    }
    if (_assessmentData['vocabulary_count'] == 'Lebih dari 50') {
      score += 20;
    } else if (_assessmentData['vocabulary_count'] == '10-50') {
      score += 10;
    }
    
    if (_assessmentData['simple_sentences'] == 'Ya') {
      score += 20;
    } else if (_assessmentData['simple_sentences'] == 'Kadang-kadang') {
      score += 10;
    }
    
    if (_assessmentData['speech_clarity'] == 'Selalu') {
      score += 20;
    } else if (_assessmentData['speech_clarity'] == 'Kadang-kadang') {
      score += 10;
    }
    
    if (_assessmentData['name_response'] == 'Selalu') {
      score += 20;
    } else if (_assessmentData['name_response'] == 'Kadang-kadang') {
      score += 10;
    }

    String level;
    String recommendation;
    Color levelColor;

    if (score >= 80) {
      level = 'Normal';
      recommendation = 'Perkembangan speech anak Anda terlihat normal. Tetap lakukan stimulasi rutin.';
      levelColor = Colors.green;
    } else if (score >= 50) {
      level = 'Perlu Perhatian';
      recommendation = 'Ada beberapa area yang perlu perhatian. Disarankan konsultasi dengan terapis.';
      levelColor = Colors.orange;
    } else {
      level = 'Perlu Terapi';
      recommendation = 'Anak Anda memerlukan evaluasi dan terapi speech delay segera.';
      levelColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Konsultasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: levelColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assessment, color: levelColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: $level',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                          Text('Skor: $score/100'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Rekomendasi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(recommendation),
              
              const SizedBox(height: 16),
              
              const Text(
                'Langkah Selanjutnya:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (score < 80) ...[
                const Text('• Jadwalkan sesi terapi dengan terapis'),
                const Text('• Lakukan latihan rutin di rumah'),
                const Text('• Pantau perkembangan secara berkala'),
              ] else ...[
                const Text('• Lanjutkan stimulasi di rumah'),
                const Text('• Evaluasi berkala setiap 6 bulan'),
              ],
            ],
          ),
        ),
        actions: [
          if (score < 80)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/jadwal');
              },
              child: const Text('Jadwalkan Terapi'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SimpleAppBar(title: 'Konsultasi Speech Delay'),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep 
                          ? theme.primaryColor 
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildConcernsStep(),
                _buildAssessmentStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Sebelumnya',
                      onPressed: _previousStep,
                      isOutlined: true,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _currentStep == 3 ? 'Selesai' : 'Selanjutnya',
                    onPressed: _currentStep == 3 ? _submitConsultation : _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Dasar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikan informasi dasar tentang anak Anda',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            label: 'Usia Anak (dalam bulan)',
            hint: 'Contoh: 24',
            controller: _childAgeController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.child_care),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Milestone Speech Delay berdasarkan usia:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneItem('12-18 bulan', 'Kata pertama, meniru suara'),
                  _buildMilestoneItem('18-24 bulan', '10-50 kata, kalimat 2 kata'),
                  _buildMilestoneItem('2-3 tahun', '200+ kata, kalimat 3-4 kata'),
                  _buildMilestoneItem('3-4 tahun', 'Cerita sederhana, tanya jawab'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(String age, String milestone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              age,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(milestone)),
        ],
      ),
    );
  }

  Widget _buildConcernsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kekhawatiran Anda',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ceritakan kekhawatiran Anda tentang perkembangan speech anak',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            label: 'Apa yang membuat Anda khawatir?',
            hint: 'Contoh: Anak belum bisa mengucapkan kata dengan jelas...',
            controller: _concernsController,
            maxLines: 4,
            prefixIcon: const Icon(Icons.help_outline),
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Gejala yang Anda amati',
            hint: 'Contoh: Sulit mengucapkan huruf R, sering menunjuk tanpa bicara...',
            controller: _symptomsController,
            maxLines: 4,
            prefixIcon: const Icon(Icons.visibility_outlined),
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Informasi Tambahan (Opsional)',
            hint: 'Riwayat keluarga, kondisi medis, dll...',
            controller: _additionalInfoController,
            maxLines: 3,
            prefixIcon: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Penilaian Cepat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jawab pertanyaan berikut untuk penilaian awal',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 24),
          
          ...List.generate(_questions.length, (index) {
            final question = _questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${question['question']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(question['options'].length, (optionIndex) {
                      final option = question['options'][optionIndex];
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _assessmentData[question['key']],
                        onChanged: (value) {
                          setState(() {
                            _assessmentData[question['key']] = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Konsultasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Periksa kembali informasi yang Anda berikan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Dasar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Usia anak: ${_childAgeController.text} bulan'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kekhawatiran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(_concernsController.text.isEmpty 
                      ? 'Tidak ada kekhawatiran khusus' 
                      : _concernsController.text),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Penilaian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._assessmentData.entries.map((entry) {
                    final question = _questions.firstWhere(
                      (q) => q['key'] == entry.key,
                      orElse: () => {'question': entry.key},
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• ${question['question']}: ${entry.value}'),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hasil konsultasi ini hanya sebagai penilaian awal. Untuk diagnosis yang akurat, konsultasikan dengan terapis profesional.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}