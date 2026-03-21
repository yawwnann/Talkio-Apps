import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voice_practice_simple_page.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../core/constants/app_constants.dart';

/// Game Menu Page
/// Halaman menu game terapi untuk anak dengan desain modern
class GameMenuPage extends ConsumerWidget {
  const GameMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Game Edukasi',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            _buildHeaderBanner(),

            const SizedBox(height: 24),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Game',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppConstants.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Game Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: gameList.length,
              itemBuilder: (context, index) {
                return _buildGameCard(context, gameList[index]);
              },
            ),

            const SizedBox(height: 32),

            // Tips Section
            _buildTipsSection(),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryBlue,
            AppConstants.lightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktunya Bermain!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih permainan seru untuk melatih kemampuan bicaramu',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.games_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    return InkWell(
      onTap: () => _navigateToGame(context, game),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (game['bgColor'] as Color).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: game['bgColor'] as Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  game['icon'] as IconData,
                  size: 38,
                  color: game['iconColor'] as Color,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              game['title'] as String,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // Description - dengan Flexible
            Flexible(
              child: Text(
                game['description'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: const Color(0xFF94A3B8),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Spacer(),

            // Badge and Coins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLevelBadge(game['level'] as String),
                _buildCoinCounter(game['coins'] as int? ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinCounter(int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money,
            size: 10,
            color: const Color(0xFFFFB74D),
          ),
          const SizedBox(width: 2),
          Text(
            '$coins',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    Color badgeColor;
    Color textColor;

    switch (level.toLowerCase()) {
      case 'level 1':
        badgeColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
      case 'baru':
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'hot':
        badgeColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'sesuaikan':
        badgeColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        badgeColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppConstants.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tips Bermain',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppConstants.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Ciptakan Suasana Ceria',
          'Berikan pujian setiap kali anak berhasil menyelesaikan satu tantangan kecil.',
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
        ),
        const SizedBox(height: 10),
        _buildTipItem(
          'Waktu Bermain Singkat',
          'Lakukan terapi sekitar 10-15 menit namun rutin setiap hari.',
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
        ),
        const SizedBox(height: 10),
        _buildTipItem(
          'Gunakan Alat Peraga',
          'Manfaatkan mainan atau benda sekitar untuk membuat sesi terapi lebih menarik.',
          const Color(0xFFDBEAFE),
          const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildTipItem(
    String title,
    String description,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                size: 16,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, Map<String, dynamic> game) {
    if (game['route'] == '/game/voice-practice') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VoicePracticeSimplePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membuka ${game['title']}...'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// Game Data
final gameList = [
  {
    'title': 'Menirukan Suara',
    'description': 'Kiri suara hewan dan benda di sekitar kita',
    'icon': Icons.volume_up_rounded,
    'bgColor': const Color(0xFFDCFCE7),
    'iconColor': const Color(0xFF16A34A),
    'level': 'Level 1',
    'coins': 0,
    'route': '/game/mimic-sound',
  },
  {
    'title': 'Tebak Gambar',
    'description': 'Sebutkan nama benda yang ada di gambar',
    'icon': Icons.image_rounded,
    'bgColor': const Color(0xFFFEF3C7),
    'iconColor': const Color(0xFFD97706),
    'level': 'Baru',
    'coins': 0,
    'route': '/game/guess-image',
  },
  {
    'title': 'Latihan Suara',
    'description': 'Rekam dan dengarkan suaramu sendiri',
    'icon': Icons.mic_rounded,
    'bgColor': const Color(0xFFDBEAFE),
    'iconColor': const Color(0xFF2563EB),
    'level': 'Hot',
    'coins': 0,
    'route': '/game/voice-practice',
  },
  {
    'title': 'Puzzle Kata',
    'description': 'Susun huruf menjadi kata yang benar',
    'icon': Icons.toys_rounded,
    'bgColor': const Color(0xFFFEE2E2),
    'iconColor': const Color(0xFFDC2626),
    'level': 'Sesuaikan',
    'coins': 0,
    'route': '/game/word-puzzle',
  },
];
