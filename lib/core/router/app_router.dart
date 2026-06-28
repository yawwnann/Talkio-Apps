import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/login_page_new.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/forgot_password_page.dart';
import '../../features/dashboard/pages/parent_dashboard_page.dart';
import '../../features/dashboard/pages/therapist_dashboard_page.dart';
import '../../features/anak/pages/anak_list_page.dart';
import '../../features/anak/pages/add_anak_page.dart';
import '../../features/anak/pages/anak_detail_page.dart';
import '../../features/anak/pages/edit_anak_page.dart';
import '../../features/konsultasi/pages/konsultasi_page.dart';
import '../../features/diagnosa/pages/diagnosa_history_page.dart';
import '../../features/diagnosa/pages/diagnosa_detail_page.dart';
import '../../features/game/pages/game_menu_page.dart';
import '../../features/game/pages/game_history_page.dart';
import '../../features/game/pages/voice_practice_simple_page.dart';
import '../../features/game/pages/suara_binatang_page.dart';
import '../../features/game/pages/tebak_suara_page.dart';
import '../../features/game/pages/latihan_artikulasi_page.dart';
import '../../features/game/pages/kata_bergambar_page.dart';
import '../../features/game/pages/cerita_interaktif_page.dart';
import '../../features/pembayaran/pages/pembayaran_list_page.dart';
import '../../features/pembayaran/pages/parent_pembayaran_page.dart';
import '../../features/pembayaran/pages/payment_webview_page.dart';
import '../../features/jadwal/pages/jadwal_terapi_page.dart';
import '../../features/jadwal/pages/therapist_jadwal_page.dart';
import '../../features/jadwal/pages/parent_jadwal_page.dart';
import '../../features/laporan/pages/therapist_report_list_page.dart';
import '../../features/laporan/pages/therapist_report_detail_page.dart';
import '../../features/laporan/pages/therapist_add_report_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/change_password_page.dart';
import '../../features/therapist/pages/patient_list_page.dart';
import '../../features/therapist/pages/patient_detail_page.dart';
import '../../features/admin/pages/admin_dashboard_page.dart';
import '../../features/admin/pages/admin_user_management_page.dart';
import '../../features/admin/pages/admin_payment_page.dart';
import '../../features/admin/pages/admin_report_page.dart';
import '../../features/admin/pages/admin_profile_page.dart';
import '../../features/admin/pages/admin_asset_management_page.dart';
import '../../features/admin/pages/admin_notification_page.dart';
import '../../features/laporan/pages/parent_report_list_page.dart';
import '../../features/laporan/pages/parent_report_detail_page.dart';
import '../../features/booking/pages/select_therapist_page.dart';
import '../../features/booking/pages/select_schedule_page.dart';
import '../../features/booking/pages/booking_confirmation_page.dart';
import '../../features/booking/pages/therapist_detail_page.dart';
import '../../features/progress/pages/progress_upload_page.dart';
import '../../features/notifikasi/pages/notifikasi_page.dart';

/// App Router Configuration
/// Konfigurasi routing aplikasi menggunakan GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = ref.watch(authProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isLoading = authState.isLoading;
        final userRole = authState.user?.role;

        // ── Splash page ───────────────────────────────────────────────────────
        // Tahan di splash sampai auth init selesai, tapi KECUALIKAN jika sudah
        // ada di halaman lain (mencegah loop setelah login).
        final isOnSplash = state.matchedLocation == '/splash';
        if (isOnSplash) return null;             // allow splash always

        // ── Block redirect while auth init is still loading ──────────────────
        // Ini mencegah redirect ke login saat aplikasi pertama kali dibuka
        // sebelum [_checkAuthStatus] selesai.
        if (isLoading) return null;

        final isOnAuthPage =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';

        // ── Not authenticated → ke login ───────────────────────────────────
        if (!isAuthenticated && !isOnAuthPage) {
          return '/login';
        }

        // ── Authenticated ───────────────────────────────────────────────────
        if (isAuthenticated) {
          // Dari halaman auth → ke dashboard sesuai role
          if (isOnAuthPage) {
            switch (userRole) {
              case 'THERAPIST':
                return '/terapis-dashboard';
              case 'ADMIN':
                return '/admin-dashboard';
              case 'PARENT':
              default:
                return '/dashboard';
            }
          }

          // Role mismatch redirect
          if (userRole == 'THERAPIST' && state.matchedLocation == '/dashboard') {
            return '/terapis-dashboard';
          }

          if (userRole == 'ADMIN' && state.matchedLocation == '/dashboard') {
            return '/admin-dashboard';
          }

          if (userRole == 'PARENT' && state.matchedLocation == '/terapis-dashboard') {
            return '/dashboard';
          }
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
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Dashboard Route
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) {
            final user = ref.watch(currentUserProvider);
            // Show therapist dashboard if user role is THERAPIST
            if (user?.isTherapist ?? false) {
              return const TherapistDashboardPage();
            }
            // Show parent dashboard for PARENT and others
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
                return EditAnakPage(anakId: id);
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

        // Diagnosa Routes
        GoRoute(
          path: '/diagnosa',
          name: 'diagnosa',
          builder: (context, state) => const DiagnosaHistoryPage(),
        ),
        GoRoute(
          path: '/diagnosa/:childId',
          name: 'diagnosa-child',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return DiagnosaHistoryPage(childId: childId);
          },
        ),
        GoRoute(
          path: '/diagnosa/:childId/:diagnosisId',
          name: 'diagnosa-detail',
          builder: (context, state) {
            final diagnosisId = state.pathParameters['diagnosisId']!;
            return DiagnosaDetailPage(diagnosisId: diagnosisId);
          },
        ),

        // Jadwal Route (role-based)
        GoRoute(
          path: '/jadwal',
          name: 'jadwal',
          builder: (context, state) {
            final user = ref.read(currentUserProvider);
            final role = user?.role ?? '';
            
            if (role == AppConstants.roleTerapis) {
              return const JadwalTerapiPage();
            } else if (role == AppConstants.roleAdmin) {
              // Admin doesn't have schedule page, redirect to dashboard
              return const AdminDashboardPage();
            } else {
              // Parent
              return const ParentJadwalPage();
            }
          },
        ),

        // Pembayaran Route (role-based)
        GoRoute(
          path: '/pembayaran',
          name: 'pembayaran',
          builder: (context, state) {
            final user = ref.read(currentUserProvider);
            final role = user?.role ?? '';
            
            if (role == AppConstants.roleTerapis || role == AppConstants.roleAdmin) {
              return const PembayaranListPage();
            } else {
              // Parent
              return const ParentPembayaranPage();
            }
          },
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
              path: 'suara-binatang',
              name: 'suara-binatang',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return SuaraBinatangPage(
                  childId: extra['childId']?.toString() ?? '',
                  choicesCount: extra['choicesCount'] ?? 2,
                  totalRounds: extra['totalRounds'] ?? 8,
                );
              },
            ),

            GoRoute(
              path: 'tebak-suara',
              name: 'tebak-suara',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return TebakSuaraPage(
                  childId: extra['childId']?.toString() ?? '',
                  totalRounds: extra['totalRounds'] ?? 8,
                );
              },
            ),
            GoRoute(
              path: 'latihan-artikulasi',
              name: 'latihan-artikulasi',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return LatihanArtikulasiPage(
                  childId: extra['childId']?.toString() ?? '',
                  totalRounds: extra['totalRounds'] ?? 8,
                  targetSound: extra['targetSound']?.toString(),
                );
              },
            ),
            GoRoute(
              path: 'kata-bergambar',
              name: 'kata-bergambar',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return KataBergambarPage(
                  childId: extra['childId']?.toString() ?? '',
                  choicesCount: extra['choicesCount'] ?? 3,
                  totalRounds: extra['totalRounds'] ?? 8,
                  hintMode: extra['hintMode']?.toString() ?? 'none',
                );
              },
            ),
            GoRoute(
              path: 'cerita-interaktif',
              name: 'cerita-interaktif',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return CeritaInteraktifPage(
                  childId: extra['childId']?.toString() ?? '',
                  storyIndex: extra['storyIndex'] ?? 0,
                );
              },
            ),

            GoRoute(
              path: 'history',
              name: 'game-history',
              builder: (context, state) => const GameHistoryPage(),
            ),
          ],
        ),

        // Booking Routes (Parent)
        GoRoute(
          path: '/booking/therapist',
          name: 'booking-therapist',
          builder: (context, state) => const SelectTherapistPage(),
        ),
        GoRoute(
          path: '/booking/therapist-detail',
          name: 'booking-therapist-detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return TherapistDetailPage(
              therapistId: extra?['therapistId'] ?? '',
              therapistName: extra?['therapistName'] ?? '',
            );
          },
        ),
        GoRoute(
          path: '/booking/schedule',
          name: 'booking-schedule',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SelectSchedulePage(
              therapistId: extra?['therapistId'] ?? '',
              therapistName: extra?['therapistName'] ?? '',
            );
          },
        ),
        GoRoute(
          path: '/booking/confirmation',
          name: 'booking-confirmation',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BookingConfirmationPage(
              bookingData: extra ?? {},
            );
          },
        ),

        // Payment WebView Route
        GoRoute(
          path: '/payment/webview',
          name: 'payment-webview',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentWebViewPage(
              paymentUrl: extra?['paymentUrl'] ?? '',
              sessionId: extra?['sessionId'] ?? '',
            );
          },
        ),

        // Laporan Route (Parent)
        GoRoute(
          path: '/laporan',
          name: 'parent-reports',
          builder: (context, state) => const ParentReportListPage(),
        ),

        // Parent Report Detail Route
        GoRoute(
          path: '/laporan/:id',
          name: 'parent-report-detail',
          builder: (context, state) {
            final reportId = state.pathParameters['id']!;
            return ParentReportDetailPage(reportId: reportId);
          },
        ),

        // Progress Upload Route
        GoRoute(
          path: '/progress/upload',
          name: 'progress-upload',
          builder: (context, state) => const ProgressUploadPage(),
        ),

        // Notifikasi Route
        GoRoute(
          path: '/notifikasi',
          name: 'notifikasi',
          builder: (context, state) => const NotificationPage(),
        ),

        // Terapis Dashboard Route
        GoRoute(
          path: '/terapis-dashboard',
          name: 'terapis-dashboard',
          builder: (context, state) => const TherapistDashboardPage(),
        ),

        // Therapist Patient Routes
        GoRoute(
          path: '/therapist/pasien',
          name: 'therapist-patient',
          builder: (context, state) => const TherapistPatientPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'therapist-patient-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final openTab = extra['openTab'] as String?;
                return TherapistPatientDetailPage(
                  patientId: id,
                  openTab: openTab,
                );
              },
            ),
          ],
        ),

        // Therapist Jadwal Route
        GoRoute(
          path: '/therapist/jadwal',
          name: 'therapist-jadwal',
          builder: (context, state) => const TherapistJadwalPage(),
        ),

        // Therapist Laporan Route
        GoRoute(
          path: '/therapist/laporan',
          name: 'therapist-laporan',
          builder: (context, state) => const TherapistReportListPage(),
        ),

        // Therapist Add/Edit Laporan Route
        GoRoute(
          path: '/therapist/laporan/add',
          name: 'therapist-laporan-add',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return TherapistAddReportPage(
              initialPatientId: extra?['patientId'] as String?,
              initialLaporanId: extra?['laporanId'] as String?,
            );
          },
        ),

        // Therapist Laporan Detail Route
        GoRoute(
          path: '/therapist/laporan/:id',
          name: 'therapist-laporan-detail',
          builder: (context, state) {
            final laporanId = state.pathParameters['id']!;
            return TherapistReportDetailPage(laporanId: laporanId);
          },
        ),

        // Admin Dashboard Route
        GoRoute(
          path: '/admin-dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),

        // Admin User Management Route
        GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          builder: (context, state) => const AdminUserManagementPage(),
        ),

        // Admin Payment Management Route
        GoRoute(
          path: '/admin/pembayaran',
          name: 'admin-payments',
          builder: (context, state) => const AdminPaymentPage(),
        ),

        // Admin Report Management Route
        GoRoute(
          path: '/admin/laporan',
          name: 'admin-reports',
          builder: (context, state) => const AdminReportPage(),
        ),

        // Admin Asset Management Route
        GoRoute(
          path: '/admin/assets',
          name: 'admin-assets',
          builder: (context, state) => const AdminAssetManagementPage(),
        ),

        // Admin Notification Route
        GoRoute(
          path: '/admin/notifikasi',
          name: 'admin-notifications',
          builder: (context, state) => const AdminNotificationPage(),
        ),

        // Profile Route (role-based)
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) {
            final user = ref.read(currentUserProvider);
            final role = user?.role ?? '';

            if (role == AppConstants.roleAdmin) {
              return const AdminProfilePage();
            } else if (role == AppConstants.roleTerapis) {
              // For now, use generic profile for therapist
              // Can create TherapistProfilePage later
              return const ProfilePage();
            } else {
              return const ProfilePage();
            }
          },
        ),

        // Edit Profile Route
        GoRoute(
          path: '/profile/edit',
          name: 'edit-profile',
          builder: (context, state) => const EditProfilePage(),
        ),

        // Change Password Route
        GoRoute(
          path: '/profile/change-password',
          name: 'change-password',
          builder: (context, state) => const ChangePasswordPage(),
        ),
      ],
      errorBuilder: (context, state) => _buildErrorPage(state.error.toString()),
    );
  }

  /// Build placeholder page for unimplemented features
  static Widget _buildPlaceholderPage(String title, String description) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.grey[400]),
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
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
