import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'profile_avatar.dart';
import 'notification_badge.dart';

/// Custom App Bar Widget
/// Widget header yang konsisten untuk semua halaman
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton;
  final bool? showLogo;
  final bool? showUserMenu;
  final bool? showNotifications; // New parameter to show notification badge
  final List<Widget>? actions;
  final VoidCallback? onBackPress;
  final VoidCallback? onLogoTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final bool? centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.showLogo,
    this.showUserMenu,
    this.showNotifications,
    this.actions,
    this.onBackPress,
    this.onLogoTap,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.bottom,
    this.elevation,
    this.centerTitle,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = backgroundColor ?? Colors.white;
    final fgColor = foregroundColor ?? AppConstants.primaryBlue;
    final isCenterTitle = centerTitle ?? true;
    final shouldShowBackButton = showBackButton ?? false;
    final shouldShowLogo = showLogo ?? false;
    final shouldShowUserMenu = showUserMenu ?? true;
    // Default: show notifications if not explicitly set to false
    final shouldShowNotifications = showNotifications ?? true;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation ?? 0,
      centerTitle: isCenterTitle,
      automaticallyImplyLeading: false,
      leading: leading ?? (shouldShowBackButton ? _buildLeading(context, fgColor) : null),
      title: _buildTitle(context, fgColor, shouldShowLogo, isCenterTitle: isCenterTitle),
      actions: _buildActions(context, fgColor, shouldShowUserMenu, shouldShowNotifications, ref),
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context, Color fgColor) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      color: fgColor,
      onPressed: onBackPress ?? () {
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      tooltip: 'Kembali',
    );
  }

  Widget _buildTitle(BuildContext context, Color fgColor, bool showLogo, {bool? isCenterTitle}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: (isCenterTitle ?? centerTitle ?? true) ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (showLogo) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.medical_services,
                      size: 20,
                      color: AppConstants.primaryBlue,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: fgColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, Color fgColor, bool showUserMenu, bool showNotifications, WidgetRef ref) {
    final actionsList = <Widget>[];

    if (actions != null) {
      actionsList.addAll(actions!);
    }

    // Show notification badge if showNotifications is true, or if showUserMenu is true (default behavior)
    if (showNotifications || showUserMenu) {
      actionsList.add(const NotificationBadge());
      actionsList.add(const SizedBox(width: 8));
    }

    if (showUserMenu) {
      actionsList.add(_buildUserMenu(context, fgColor, ref));
      actionsList.add(const SizedBox(width: 16));
    }

    return actionsList;
  }

  Widget _buildUserMenu(BuildContext context, Color fgColor, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';

    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: ProfileAvatar(
        name: userName,
        radius: 18,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 12),
            Text('Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Call logout through Riverpod
      final ref = ProviderScope.containerOf(context, listen: false);
      await ref.read(authProvider.notifier).logout();
      
      if (context.mounted) {
        // Navigate to login page
        context.go('/login');
      }
    }
  }
}

/// Simple App Bar (tanpa user menu)
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPress;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.onBackPress,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;
    final fgColor = foregroundColor ?? AppConstants.primaryBlue;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: fgColor,
        onPressed: onBackPress ?? () {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Kembali',
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: fgColor,
        ),
      ),
      actions: actions,
    );
  }
}
