import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ChoiceCard
/// Kartu pilihan yang dipakai di Suara Binatang dan Kata Bergambar.
/// Mendukung emoji (dengan ukuran besar untuk anak 1-5 tahun).
/// Animasi scale on tap + warna feedback benar/salah.
class ChoiceCard extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final bool? isCorrect; // null = belum dipilih, true = benar, false = salah
  final VoidCallback onTap;
  final double size;

  const ChoiceCard({
    super.key,
    required this.emoji,
    required this.label,
    this.isSelected = false,
    this.isCorrect,
    required this.onTap,
    this.size = 80,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _bgColor {
    if (widget.isCorrect == true) return const Color(0xFFDCFCE7);
    if (widget.isCorrect == false) return const Color(0xFFFEE2E2);
    return Colors.white;
  }

  Color get _borderColor {
    if (widget.isCorrect == true) return const Color(0xFF16A34A);
    if (widget.isCorrect == false) return const Color(0xFFDC2626);
    return const Color(0xFFE2E8F0);
  }

  Color get _labelColor {
    if (widget.isCorrect == true) return const Color(0xFF16A34A);
    if (widget.isCorrect == false) return const Color(0xFFDC2626);
    return const Color(0xFF1E293B);
  }

  IconData? get _icon {
    if (widget.isCorrect == true) return Icons.check_circle;
    if (widget.isCorrect == false) return Icons.cancel;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: _borderColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji besar — mudah dibaca anak
              Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.size * 0.5),
              ),
              const SizedBox(height: 8),
              // Label
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (_icon != null) ...[
                const SizedBox(height: 4),
                Icon(_icon, color: _borderColor, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}