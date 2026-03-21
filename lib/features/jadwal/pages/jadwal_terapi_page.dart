import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';

class JadwalTerapiPage extends ConsumerStatefulWidget {
  const JadwalTerapiPage({super.key});

  @override
  ConsumerState<JadwalTerapiPage> createState() => _JadwalTerapiPageState();
}

class _JadwalTerapiPageState extends ConsumerState<JadwalTerapiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(
        title: 'Talkio',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Tugas Hari Ini', 'Lihat Semua'),
            const SizedBox(height: 16),
            _buildTasks(),
            const SizedBox(height: 32),
            _buildNextSessionCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Tips Hari Ini', null),
            const SizedBox(height: 16),
            _buildTips(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 2),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Ayah & Bunda!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ini jadwal terapi untuk Budi hari ini.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF005BAC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005BAC).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PROGRES MINGGUAN',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '4',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ 7 tugas selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: 4 / 7,
                      strokeWidth: 6,
                      backgroundColor: Color(0xFF004482),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFB800),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF004482),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.show_chart,
                      color: Color(0xFFFFB800),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 4 / 7,
              minHeight: 8,
              backgroundColor: Color(0xFF004482),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF005BAC),
            ),
          ),
      ],
    );
  }

  Widget _buildTasks() {
    return Column(
      children: [
        _buildTaskItem(
          icon: Icons.mic,
          iconBgColor: const Color(0xFFE5F0FF),
          iconColor: const Color(0xFF005BAC),
          title: 'Latihan Huruf S',
          subtitle: 'Perekaman Suara • 5 Menit',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          icon: Icons.extension,
          iconBgColor: const Color(0xFFFBF0E6),
          iconColor: const Color(0xFF8B5A2B),
          title: 'Tebak Gambar Hewan',
          subtitle: 'Game Interaktif • 10 Menit',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          icon: Icons.play_arrow,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          title: 'Cek Video Edukasi',
          subtitle: 'Video • 3 Menit',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBgColor,
              radius: 24,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSessionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sesi Tatap Muka\nBerikutnya',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_camera_front,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Kamis, 24 Okt 2023',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '14:00 - 15:30 WIB',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Lihat Detail Lokasi',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Row(
      children: [
        Expanded(
          child: _buildTipCard(
            icon: Icons.lightbulb,
            iconBgColor: const Color(0xFFFFB800),
            iconColor: const Color(0xFF8C6600),
            bgColor: const Color(0xFFFFF9E6),
            title: 'Cara Stimulasi Bicara di Rumah',
            desc: 'Tips sederhana melalui aktivitas makan.',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTipCard(
            icon: Icons.menu_book,
            iconBgColor: const Color(0xFF7AA8FF),
            iconColor: const Color(0xFF003399),
            bgColor: const Color(0xFFEBF3FF),
            title: 'Memahami Mood Si Kecil',
            desc: 'Panduan bagi orang tua menghadapi tantrum.',
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
