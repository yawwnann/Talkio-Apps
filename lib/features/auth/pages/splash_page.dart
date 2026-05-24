import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Splash Page — logo statis tanpa animasi.
/// HANYA muncul saat aplikasi pertama kali dibuka.
/// Setelah login berhasil, splash TIDAK PERNAH muncul lagi.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterAuthCheck();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _navigateAfterAuthCheck() async {
    if (_hasNavigated) return;
    if (!mounted) return;

    await ref
        .read(authProvider.notifier)
        .waitForInitComplete()
        .timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      final userRole = authState.user?.role ?? AppConstants.roleOrangTua;
      print('🚀 Splash: Auth done, role=$userRole → /dashboard');
      context.go('/dashboard');
    } else {
      print('🚀 Splash: Auth done → /login');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (statis, tidak ada animasi)
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/icons/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'Pondok Terapi Bicara',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBlue,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
