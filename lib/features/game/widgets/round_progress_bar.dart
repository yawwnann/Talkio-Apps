import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';

/// RoundProgressBar
/// Step indicator menunjukkan ronde saat ini dan total ronde.
/// Dipakai di semua game untuk tracking progress.
class RoundProgressBar extends StatelessWidget {
  final int currentRound; // 1-based
  final int totalRounds;

  const RoundProgressBar({
    super.key,
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ronde $currentRound',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textDark,
              ),
            ),
            Text(
              ' dari $totalRounds',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppConstants.textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalRounds, (index) {
            final roundNum = index + 1;
            final isCompleted = roundNum < currentRound;
            final isCurrent = roundNum == currentRound;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 28 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppConstants.successGreen
                      : isCurrent
                          ? AppConstants.primaryBlue
                          : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Progress text
        Text(
          '(${currentRound - 1}/$totalRounds benar)',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppConstants.textLight,
          ),
        ),
      ],
    );
  }
}