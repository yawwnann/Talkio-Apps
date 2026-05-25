import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/models/game_recommendation_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../anak/providers/anak_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_recommendation_provider.dart';
import 'voice_practice_simple_page.dart';

/// Game Menu Page
/// Menu game: pilih anak â†’ tampilkan rekomendasi game berdasarkan umur
class GameMenuPage extends ConsumerStatefulWidget {
  const GameMenuPage({super.key});

  @override
  ConsumerState<GameMenuPage> createState() => _GameMenuPageState();
}

class _GameMenuPageState extends ConsumerState<GameMenuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch children list if not loaded
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(anakProvider.notifier).getAnakList(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final selectedAnak = anakState.selectedAnak;

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
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            _buildChildPicker(context, anakState),
            const SizedBox(height: 16),

            _buildRecommendationsSection(context, selectedAnak),

            const SizedBox(height: 24),

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

            const SizedBox(height: 28),
            _buildTipsSection(),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 3),
    );
  }

  Widget _buildChildPicker(BuildContext context, AnakState anakState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Anak',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          if (anakState.isLoading && anakState.anakList.isEmpty)
            const LinearProgressIndicator(minHeight: 3)
          else if (anakState.error != null)
            Text(
              anakState.error ?? 'Gagal memuat data anak',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
            )
          else if (anakState.anakList.isEmpty)
            Text(
              'Belum ada data anak. Tambahkan anak dulu di menu Anak.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            )
          else
            DropdownButtonFormField<AnakModel>(
              initialValue: anakState.selectedAnak,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('Pilih anak'),
              items: anakState.anakList
                  .map(
                    (anak) => DropdownMenuItem<AnakModel>(
                      value: anak,
                      child: Text('${anak.name} • ${anak.age} th'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                ref.read(anakProvider.notifier).selectAnak(value);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context, AnakModel? selectedAnak) {
    if (selectedAnak == null) {
      return _buildEmptyRecommendations();
    }

    final recState =
        ref.watch(gameRecommendationByChildProvider(selectedAnak.id));

    if (recState.isLoading) {
      return _buildLoadingRecommendations();
    }

    if (recState.error != null) {
      return _buildErrorRecommendations(recState.error);
    }

    final rec = recState.recommendations;
    if (rec == null || rec.games.isEmpty) {
      return _buildEmptyRecommendations(
        subtitle: 'Belum ada rekomendasi untuk anak ini.',
      );
    }

    final bandLabel = rec.band?.label ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rekomendasi Game',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$bandLabel • ${rec.ageMonths} bln',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rec.games.map((g) => _buildRecommendationCard(context, g)),
      ],
    );
  }

  Widget _buildLoadingRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Memuat rekomendasi game...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRecommendations(String? message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message ?? 'Gagal memuat rekomendasi',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyRecommendations({String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi Game',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle ?? 'Pilih anak untuk melihat game yang relevan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, GameRecommendationItem recItem) {
    final title = recItem.gameType;
    final params = recItem.params;

    final chips = <Widget>[];
    if (params['choicesCount'] != null) {
      chips.add(_chip('${params['choicesCount']} pilihan'));
    }
    if (params['rounds'] != null) {
      chips.add(_chip('${params['rounds']} ronde'));
    }
    if (params['hintMode'] != null) {
      chips.add(_chip('hint: ${params['hintMode']}'));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.games_rounded, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: chips),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mulai "$title" (kerangka dulu, game menyusul)'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            color: AppConstants.primaryBlue,
          )
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
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
            color: AppConstants.primaryBlue.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.2),
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
              color: (game['bgColor'] as Color).withValues(alpha: 0.3),
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
                  color: iconColor.withValues(alpha: 0.2),
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


