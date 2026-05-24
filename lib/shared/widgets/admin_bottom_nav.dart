import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

/// Admin Bottom Navigation
/// Widget navigasi bawah khusus untuk user role Admin
class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home_outlined,
                Icons.home,
                'Home',
                0,
                '/admin-dashboard',
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                Icons.people,
                'User',
                1,
                '/admin/users',
              ),
              _buildNavItem(
                context,
                Icons.payment_outlined,
                Icons.payment,
                'Bayar',
                2,
                '/admin/pembayaran',
              ),
              _buildNavItem(
                context,
                Icons.analytics_outlined,
                Icons.analytics,
                'Laporan',
                3,
                '/admin/laporan',
              ),
              _buildNavItem(
                context,
                Icons.folder_outlined,
                Icons.folder,
                'Asset',
                4,
                '/admin/assets',
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                Icons.person,
                'Profil',
                5,
                '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
    String route,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppConstants.primaryBlue : const Color(0xFF94A3B8);

    return Flexible(
      child: InkWell(
        onTap: () {
          if (currentIndex != index) {
            context.go(route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConstants.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
