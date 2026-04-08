import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Reusable profile avatar widget with placeholder support
/// Shows initials or person icon when no image is available
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderWidth;
  final Color? borderColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.borderWidth = 0,
    this.borderColor,
  });

  /// Get initials from name (e.g., "Siti Nurhaliza" -> "SN")
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Generate consistent background color based on name
  Color _getBackgroundColor(String? name) {
    if (backgroundColor != null) return backgroundColor!;
    
    final colors = [
      AppConstants.primaryBlue,
      AppConstants.darkBlue,
      AppConstants.lightBlue,
      AppConstants.accentBlue,
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
    ];
    
    if (name == null || name.isEmpty) return colors[0];
    
    // Use name hash to pick a consistent color
    final hash = name.hashCode.abs() % colors.length;
    return colors[hash];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(name);
    final txtColor = textColor ?? Colors.white;
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.white,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(bgColor, txtColor);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(bgColor, txtColor);
                },
              )
            : _buildPlaceholder(bgColor, txtColor),
      ),
    );
  }

  Widget _buildPlaceholder(Color bgColor, Color txtColor) {
    return Container(
      color: bgColor,
      child: Center(
        child: name != null && name!.isNotEmpty
            ? Text(
                _getInitials(name),
                style: TextStyle(
                  color: txtColor,
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: txtColor,
                size: radius * 1.2,
              ),
      ),
    );
  }
}
