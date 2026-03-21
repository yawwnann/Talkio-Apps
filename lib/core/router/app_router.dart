import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/login_page_new.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/dashboard/pages/parent_dashboard_page.dart';
import '../../features/dashboard/pages/therapist_dashboard_page.dart';
import '../../features/anak/pages/anak_list_page.dart';
import '../../features/anak/pages/add_anak_page.dart';
import '../../features/anak/pages/anak_detail_page.dart';
import '../../features/konsultasi/pages/konsultasi_page.dart';
import '../../features/game/pages/game_menu_page.dart';
import '../../features/game/pages/voice_practice_simple_page.dart';
import '../../features/pembayaran/pages/pembayaran_list_page.dart';
import '../../features/jadwal/pages/jadwal_terapi_page.dart';
import '../../features/profile/pages/profile_page.dart';

/// App Router Configuration
/// Konfigurasi routing aplikasi menggunakan GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isLoading = authState.isLoading;
        
        // Don't redirect while loading
        if (isLoading) return null;
        
        final isOnAuthPage = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register';
        final isOnSplash = state.matchedLocation == '/splash';
        
        // Allow splash page
        if (isOnSplash) return null;
        
        // Redirect to login if not authenticated and not on auth page
        if (!isAuthenticated && !isOnAuthPage) {
          return '/login';
        }
        
        // Redirect to dashboard if authenticated and on auth page
        if (isAuthenticated && isOnAuthPage) {
          return '/dashboard';
        }
        
        return null;
      },
      routes: [
        // Splash Route
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        
        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPageNew(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        
        // Dashboard Route
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) {
            final user = ref.read(currentUserProvider);
            // Show therapist dashboard if user role is terapis
            if (user?.role == 'terapis') {
              return const TherapistDashboardPage();
            }
            // Show parent dashboard for orang_tua and others
            return const ParentDashboardPage();
          },
        ),
        
        // Anak Routes
        GoRoute(
          path: '/anak',
          name: 'anak-list',
          builder: (context, state) => const AnakListPage(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'anak-add',
              builder: (context, state) => const AddAnakPage(),
            ),
            GoRoute(
              path: 'edit/:id',
              name: 'anak-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return _buildPlaceholderPage('Edit Anak', 'ID: $id');
              },
            ),
            GoRoute(
              path: 'detail/:id',
              name: 'anak-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return AnakDetailPage(anakId: id);
              },
            ),
          ],
        ),
        
        // Konsultasi Route
        GoRoute(
          path: '/konsultasi',
          name: 'konsultasi',
          builder: (context, state) => const KonsultasiPage(),
        ),
        
        // Diagnosa Route
        GoRoute(
          path: '/diagnosa',
          name: 'diagnosa',
          builder: (context, state) => _buildPlaceholderPage(
            'Diagnosa',
            'Halaman hasil diagnosa speech delay',
          ),
        ),
        
        // Jadwal Route
        GoRoute(
          path: '/jadwal',
          name: 'jadwal',
          builder: (context, state) => const JadwalTerapiPage(),
        ),
        
        // Pembayaran Route
        GoRoute(
          path: '/pembayaran',
          name: 'pembayaran',
          builder: (context, state) => const PembayaranListPage(),
        ),
        
        // Game Route
        GoRoute(
          path: '/game',
          name: 'game',
          builder: (context, state) => const GameMenuPage(),
          routes: [
            GoRoute(
              path: 'voice-practice',
              name: 'voice-practice',
              builder: (context, state) => const VoicePracticeSimplePage(),
            ),
            GoRoute(
              path: 'mimic-sound',
              name: 'mimic-sound',
              builder: (context, state) => _buildPlaceholderPage(
                'Menirukan Suara',
                'Game menirukan suara hewan dan benda',
              ),
            ),
            GoRoute(
              path: 'guess-image',
              name: 'guess-image',
              builder: (context, state) => _buildPlaceholderPage(
                'Tebak Gambar',
                'Game tebak nama benda dari gambar',
              ),
            ),
            GoRoute(
              path: 'word-puzzle',
              name: 'word-puzzle',
              builder: (context, state) => _buildPlaceholderPage(
                'Puzzle Kata',
                'Game susun huruf menjadi kata',
              ),
            ),
          ],
        ),
        
        // Edukasi Route
        GoRoute(
          path: '/edukasi',
          name: 'edukasi',
          builder: (context, state) => _buildPlaceholderPage(
            'Edukasi',
            'Halaman materi edukasi',
          ),
        ),
        
        // Laporan Route
        GoRoute(
          path: '/laporan',
          name: 'laporan',
          builder: (context, state) => _buildPlaceholderPage(
            'Laporan',
            'Halaman laporan perkembangan',
          ),
        ),
        
        // Notifikasi Route
        GoRoute(
          path: '/notifikasi',
          name: 'notifikasi',
          builder: (context, state) => _buildPlaceholderPage(
            'Notifikasi',
            'Halaman notifikasi',
          ),
        ),
        
        // Terapis Dashboard Route
        GoRoute(
          path: '/terapis-dashboard',
          name: 'terapis-dashboard',
          builder: (context, state) => const TherapistDashboardPage(),
        ),
        
        // Admin Dashboard Route
        GoRoute(
          path: '/admin-dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => _buildPlaceholderPage(
            'Dashboard Admin',
            'Dashboard untuk admin',
          ),
        ),

        // Profile Route
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      errorBuilder: (context, state) => _buildErrorPage(state.error.toString()),
    );
  }
  
  /// Build placeholder page for unimplemented features
  static Widget _buildPlaceholderPage(String title, String description) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Halaman ini sedang dalam pengembangan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build error page
  static Widget _buildErrorPage(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}