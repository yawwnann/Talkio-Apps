import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../../shared/widgets/therapist_bottom_nav.dart';
import '../../../shared/widgets/admin_bottom_nav.dart';
import '../../../shared/widgets/profile_avatar.dart';

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 16),
          _buildQuickStats(user),
          const SizedBox(height: 16),
          _buildMenuSection(user),
          const SizedBox(height: 16),
          _buildLogoutButton(ref),
          const SizedBox(height: 24),
        ],
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

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'THERAPIST': return 'Terapis';
      case 'ADMIN': return 'Admin';
      default: return 'Orang Tua';
    }
  }

  Widget _buildProfileHeader(dynamic user) {
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final roleLabel = _getRoleLabel(user?.role);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryBlue, Color(0xFF0077E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
                Text(name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleLabel,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(email,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(dynamic user) {
    final role = user?.role ?? '';
    final icons = <Widget>[];

    if (role == 'THERAPIST') {
      icons.addAll([
        _buildQuickIcon(Icons.people, 'Pasien', () => context.go('/therapist/pasien')),
        _buildQuickIcon(Icons.calendar_today, 'Jadwal', () => context.go('/jadwal')),
        _buildQuickIcon(Icons.assignment, 'Laporan', () => context.go('/therapist/laporan')),
        _buildQuickIcon(Icons.dashboard, 'Dashboard', () => context.go('/terapis-dashboard')),
      ]);
    } else if (role == 'ADMIN') {
      icons.addAll([
        _buildQuickIcon(Icons.people, 'Users', () => context.go('/admin/users')),
        _buildQuickIcon(Icons.payments, 'Pembayaran', () => context.go('/admin/pembayaran')),
        _buildQuickIcon(Icons.assessment, 'Laporan', () => context.go('/admin/laporan')),
        _buildQuickIcon(Icons.dashboard, 'Dashboard', () => context.go('/admin-dashboard')),
      ]);
    } else {
      icons.addAll([
        _buildQuickIcon(Icons.calendar_today, 'Jadwal', () => context.go('/jadwal')),
        _buildQuickIcon(Icons.games, 'Game', () => context.go('/game')),
        _buildQuickIcon(Icons.chat_bubble, 'Konsultasi', () => context.go('/konsultasi')),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: icons),
    );
  }

  Widget _buildQuickIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppConstants.lightBlue, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: AppConstants.primaryBlue),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMenuSection(dynamic user) {
    final isTherapist = user?.role == 'THERAPIST';

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Edit Profil', () => context.push('/profile/edit')),
          _buildMenuItem(Icons.shield_outlined, 'PIN Pemulihan', () => _showRecoveryPinDialog()),
          if (isTherapist) _buildMenuItem(Icons.calendar_today_outlined, 'Jadwal Terapi', () => context.go('/jadwal')),
          _buildMenuItem(Icons.notifications_outlined, 'Notifikasi', () => context.push('/notifikasi')),
          _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', () => _showAboutDialog()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryBlue),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(ref),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text('Keluar', style: GoogleFonts.poppins(color: Colors.red, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showRecoveryPinDialog() async {
    final user = ref.read(currentUserProvider);
    final hasPin = user?.hasRecoveryPin ?? false;

    final oldPinC = TextEditingController();
    final newPinC = TextEditingController();
    final confirmPinC = TextEditingController();
    bool loading = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, size: 22, color: AppConstants.primaryBlue),
              const SizedBox(width: 8),
              Text(
                hasPin ? 'Ubah PIN Pemulihan' : 'Aktifkan PIN Pemulihan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPin
                      ? 'Masukkan PIN lama, lalu buat PIN baru 6 digit.'
                      : 'Buat PIN 6 digit untuk memulihkan akun jika lupa password.',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                if (hasPin) ...[
                  TextField(
                    controller: oldPinC,
                    obscureText: obscureOld,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'PIN Lama',
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: newPinC,
                  obscureText: obscureNew,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: hasPin ? 'PIN Baru' : 'PIN Pemulihan',
                    labelStyle: GoogleFonts.poppins(fontSize: 13),
                    hintText: '6 digit angka',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFCBD5E1)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPinC,
                  obscureText: obscureConfirm,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi PIN',
                    labelStyle: GoogleFonts.poppins(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final newPin = newPinC.text.trim();
                      final confirmPin = confirmPinC.text.trim();
                      final oldPin = oldPinC.text.trim();

                      if (hasPin && oldPin.isEmpty) {
                        _showSnackBar('PIN lama harus diisi.', isError: true);
                        return;
                      }
                      if (newPin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(newPin)) {
                        _showSnackBar('PIN baru harus 6 digit angka.', isError: true);
                        return;
                      }
                      if (newPin != confirmPin) {
                        _showSnackBar('PIN baru tidak cocok.', isError: true);
                        return;
                      }

                      setDialogState(() => loading = true);
                      try {
                        final api = ApiService();
                        final response = await api.setRecoveryPin(
                          newPin: newPin,
                          oldPin: hasPin ? oldPin : null,
                        );
                        if (response.statusCode == 200) {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).refreshProfile();
                          _showSnackBar(
                            hasPin ? 'PIN pemulihan berhasil diubah.' : 'PIN pemulihan berhasil diaktifkan.',
                          );
                        } else {
                          final msg = response.data is Map ? response.data['message'] ?? 'Gagal menyimpan PIN.' : 'Gagal menyimpan PIN.';
                          _showSnackBar(msg, isError: true);
                        }
                      } catch (e) {
                        _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
                      }
                      if (ctx.mounted) setDialogState(() => loading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(hasPin ? 'Ubah PIN' : 'Aktifkan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppConstants.primaryBlue, Color(0xFF0077E6)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('Terapi Wicara', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Versi 1.0.0', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 16),
          Text(
            'Aplikasi pendeteksi dini keterlambatan bicara pada anak dengan fitur konsultasi, terapi game, dan monitoring perkembangan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), height: 1.6),
          ),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(c),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Tutup', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.logout_rounded, size: 32, color: Colors.red),
          ),
          const SizedBox(height: 20),
          Text('Keluar Aplikasi?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Anda harus login kembali untuk mengakses aplikasi',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
          ),
        ]),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(c),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Batal', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () { ref.read(authProvider.notifier).logout(); context.go('/login'); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Keluar', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
