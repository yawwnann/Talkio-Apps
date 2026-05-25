import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';

/// Profile Page
/// Halaman profil pengguna dengan desain modern dan clean
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(
        title: 'Profil',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildMenuSection(),
            const SizedBox(height: 16),
            _buildAppSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(user),
    );
  }

  Widget _buildBottomNavBar(dynamic user) {
    final role = user?.role ?? '';

    if (role == AppConstants.roleTerapis) {
      return TherapistBottomNav(currentIndex: 4);
    } else if (role == AppConstants.roleAdmin) {
      return AdminBottomNav(currentIndex: 5);
    } else {
      return ParentBottomNav(currentIndex: 5);
    }
  }

  /// Get display label for user role
  String _getRoleLabel(String? role) {
    switch (role) {
      case 'THERAPIST':
        return 'Terapis';
      case 'ADMIN':
        return 'Admin';
      case 'PARENT':
      default:
        return 'Orang Tua';
    }
  }

  Widget _buildProfileHeader(dynamic user) {
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final roleLabel = _getRoleLabel(user?.role);
    final isTherapist = user?.role == 'THERAPIST';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppConstants.primaryBlue,
            Color(0xFF0077E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(
                imageUrl: null,
                name: name,
                radius: 32,
                borderWidth: 2,
                borderColor: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            roleLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isTherapist
                  ? [
                      _buildStatItem('24', 'Total Pasien'),
                      _buildDivider(),
                      _buildStatItem('48', 'Sesi Bulan Ini'),
                      _buildDivider(),
                      _buildStatItem('36', 'Laporan'),
                    ]
                  : [
                      _buildStatItem('3', 'Anak'),
                      _buildDivider(),
                      _buildStatItem('12', 'Konsultasi'),
                      _buildDivider(),
                      _buildStatItem('24', 'Game'),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildQuickStats() {
    final user = ref.watch(currentUserProvider);
    final isTherapist = user?.role == 'THERAPIST';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: isTherapist
            ? [
                _buildQuickStatIcon(
                  Icons.calendar_today,
                  'Jadwal',
                  const Color(0xFFE3F2FD),
                  const Color(0xFF2196F3),
                  () => context.go('/jadwal'),
                ),
                _buildQuickStatIcon(
                  Icons.people,
                  'Pasien',
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                  () => context.go('/therapist/pasien'),
                ),
                _buildQuickStatIcon(
                  Icons.assignment,
                  'Laporan',
                  const Color(0xFFFFF9E6),
                  const Color(0xFFB8860B),
                  () => context.go('/therapist/reports'),
                ),
                _buildQuickStatIcon(
                  Icons.dashboard,
                  'Dashboard',
                  const Color(0xFFF3E5F5),
                  const Color(0xFF9C27B0),
                  () => context.go('/dashboard'),
                ),
              ]
            : [
                _buildQuickStatIcon(
                  Icons.calendar_today,
                  'Jadwal',
                  const Color(0xFFE3F2FD),
                  const Color(0xFF2196F3),
                  () => context.go('/jadwal'),
                ),
                _buildQuickStatIcon(
                  Icons.games,
                  'Game',
                  const Color(0xFFFFF9E6),
                  const Color(0xFFB8860B),
                  () => context.go('/game'),
                ),
                _buildQuickStatIcon(
                  Icons.chat_bubble,
                  'Konsultasi',
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                  () => context.go('/konsultasi'),
                ),
              ],
      ),
    );
  }

  Widget _buildQuickStatIcon(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final user = ref.watch(currentUserProvider);
    final isTherapist = user?.role == 'THERAPIST';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pengaturan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildMenuItem(
            Icons.person_outline_rounded,
            'Edit Profil',
            'Kelola informasi pribadi',
            const Color(0xFFE3F2FD),
            const Color(0xFF2196F3),
            () {
              // Navigate to edit profile
            },
          ),
          _buildMenuItem(
            Icons.security_outlined,
            'Keamanan',
            'Password & privasi',
            const Color(0xFFE8F5E9),
            const Color(0xFF4CAF50),
            () {
              // Navigate to security
            },
          ),
          _buildMenuItem(
            Icons.notifications_outlined,
            'Notifikasi',
            'Atur notifikasi aplikasi',
            const Color(0xFFFFF9E6),
            const Color(0xFFB8860B),
            () {
              // Navigate to notifications
            },
          ),
          if (isTherapist)
            _buildMenuItem(
              Icons.assignment_outlined,
              'Data & Laporan',
              'Kelola laporan pasien',
              const Color(0xFFF3E5F5),
              const Color(0xFF9C27B0),
              () {
                // Navigate to data & reports
              },
            ),
          if (isTherapist)
            _buildMenuItem(
              Icons.calendar_today_outlined,
              'Jadwal Terapi',
              'Kelola jadwal sesi',
              const Color(0xFFE0F7FA),
              const Color(0xFF00BCD4),
              () {
                context.go('/jadwal');
              },
            ),
          _buildMenuItem(
            Icons.help_outline_rounded,
            'Pusat Bantuan',
            'FAQ & dukungan',
            const Color(0xFFECEFF1),
            const Color(0xFF607D8B),
            () {
              // Navigate to help center
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Umum',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildMenuItem(
            Icons.info_outline_rounded,
            'Tentang Aplikasi',
            'Versi 1.0.0',
            const Color(0xFFECEFF1),
            const Color(0xFF607D8B),
            () {
              _showAboutDialog();
            },
          ),
          _buildMockDataToggle(ref),
          _buildMenuItem(
            Icons.description_outlined,
            'Syarat & Ketentuan',
            '',
            const Color(0xFFFFF3E0),
            const Color(0xFFFF9800),
            () {
              // Navigate to terms
            },
          ),
          _buildMenuItem(
            Icons.privacy_tip_outlined,
            'Kebijakan Privasi',
            '',
            const Color(0xFFE8EAF6),
            const Color(0xFF3F51B5),
            () {
              // Navigate to privacy policy
            },
          ),
          const Divider(height: 1),
          Builder(
            builder: (BuildContext context) {
              return _buildLogoutButton(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockDataToggle(WidgetRef ref) {
    final useMockData = ref.watch(mockModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: useMockData ? const Color(0xFFFFF9E6) : const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storage_rounded,
              size: 20,
              color: useMockData ? const Color(0xFFB8860B) : const Color(0xFF607D8B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Demo',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  useMockData ? 'Menggunakan data mock' : 'Menggunakan API real',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: useMockData,
            onChanged: (value) {
              ref.read(authProvider.notifier).toggleMockMode(value);
            },
            activeColor: AppConstants.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showLogoutDialog(ref),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppConstants.primaryBlue,
                      Color(0xFF0077E6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Terapi Wicara',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versi 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aplikasi pendeteksi dini keterlambatan bicara pada anak dengan fitur konsultasi, terapi game, dan monitoring perkembangan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2026 Terapi Wicara. All rights reserved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Keluar Aplikasi?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda harus login kembali untuk mengakses aplikasi',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
