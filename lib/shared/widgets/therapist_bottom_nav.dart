import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

/// Therapist Bottom Navigation
/// Widget navigasi bawah khusus untuk user role Terapis
class TherapistBottomNav extends StatelessWidget {
  final int currentIndex;

  const TherapistBottomNav({
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
                '/terapis-dashboard',
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                Icons.people,
                'Pasien',
                1,
                '/therapist/pasien',
              ),
              _buildNavItem(
                context,
                Icons.calendar_today_outlined,
                Icons.calendar_today,
                'Jadwal',
                2,
                '/therapist/jadwal',
              ),
              _buildNavItem(
                context,
                Icons.assessment_outlined,
                Icons.assessment,
                'Laporan',
                3,
                '/therapist/laporan',
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                Icons.person,
                'Profil',
                4,
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
