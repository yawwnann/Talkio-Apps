import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

/// Therapist Navigation Rail
/// Widget navigasi samping khusus untuk user role Terapis
class TherapistNavRail extends StatelessWidget {
  final int currentIndex;
  final bool isCollapsed;
  final VoidCallback? onDestinationSelected;

  const TherapistNavRail({
    super.key,
    required this.currentIndex,
    this.isCollapsed = false,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: const Text('Beranda'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: const Icon(Icons.people),
        label: const Text('Pasien'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.calendar_today_outlined),
        selectedIcon: const Icon(Icons.calendar_today),
        label: const Text('Jadwal'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.assessment_outlined),
        selectedIcon: const Icon(Icons.assessment),
        label: const Text('Laporan'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: const Text('Profil'),
      ),
    ];

    return NavigationRail(
      extended: !isCollapsed,
      minExtendedWidth: 200,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        _navigateToRoute(context, index);
        onDestinationSelected?.call();
      },
      leading: isCollapsed
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terapi Wicara',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
      trailing: const Spacer(),
      destinations: destinations,
    );
  }

  void _navigateToRoute(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/terapis-dashboard');
        break;
      case 1:
        context.go('/therapist/pasien');
        break;
      case 2:
        context.go('/therapist/jadwal');
        break;
      case 3:
        context.go('/therapist/laporan');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

/// Admin Navigation Rail
/// Widget navigasi samping khusus untuk user role Admin
class AdminNavRail extends StatelessWidget {
  final int currentIndex;
  final bool isCollapsed;
  final VoidCallback? onDestinationSelected;

  const AdminNavRail({
    super.key,
    required this.currentIndex,
    this.isCollapsed = false,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: const Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: const Icon(Icons.people),
        label: const Text('User'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.payment_outlined),
        selectedIcon: const Icon(Icons.payment),
        label: const Text('Pembayaran'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.calendar_today_outlined),
        selectedIcon: const Icon(Icons.calendar_today),
        label: const Text('Jadwal'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.analytics_outlined),
        selectedIcon: const Icon(Icons.analytics),
        label: const Text('Laporan'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: const Text('Settings'),
      ),
    ];

    return NavigationRail(
      extended: !isCollapsed,
      minExtendedWidth: 200,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        _navigateToRoute(context, index);
        onDestinationSelected?.call();
      },
      leading: isCollapsed
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
      trailing: const Spacer(),
      destinations: destinations,
    );
  }

  void _navigateToRoute(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin-dashboard');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/pembayaran');
        break;
      case 3:
        context.go('/admin/jadwal');
        break;
      case 4:
        context.go('/admin/laporan');
        break;
      case 5:
        context.go('/admin/settings');
        break;
    }
  }
}

/// Responsive Navigation Layout
/// Wrapper untuk navigasi yang responsif (mobile vs tablet/desktop)
class ResponsiveNavLayout extends StatelessWidget {
  final Widget body;
  final Widget bottomNav;
  final Widget navRail;
  final bool showRail;

  const ResponsiveNavLayout({
    super.key,
    required this.body,
    required this.bottomNav,
    required this.navRail,
    this.showRail = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Show navigation rail on wider screens (>600px)
        if (constraints.maxWidth > 600 && showRail) {
          return Row(
            children: [
              navRail,
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          );
        }

        // Show bottom navigation on mobile
        return Scaffold(body: body, bottomNavigationBar: bottomNav);
      },
    );
  }
}
