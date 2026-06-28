import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/models/notification_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Notifikasi',
        showBackButton: true,
        showLogo: false,
        showUserMenu: false,
        showNotifications: false,
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Baca Semua button
                    if (notificationState.unreadCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextButton.icon(
                          onPressed: () {
                            ref.read(notificationProvider.notifier).markAllAsRead();
                          },
                          icon: const Icon(Icons.done_all_rounded, size: 18),
                          label: Text(
                            'Baca Semua (${notificationState.unreadCount})',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppConstants.primaryBlue,
                            backgroundColor: AppConstants.primaryBlue.withValues(alpha: 0.08),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    // Notification list
                    Expanded(
                      child: _buildNotificationList(context, ref, notificationState.notifications),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationModel> notifications,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).fetchNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(context, ref, notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    final icon = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);
    final bgColor = iconColor.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: notification.isRead ? Colors.white : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        elevation: notification.isRead ? 0 : 2,
        shadowColor: notification.isRead
            ? Colors.transparent
            : AppConstants.primaryBlue.withValues(alpha: 0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (!notification.isRead) {
              await ref.read(notificationProvider.notifier).markAsRead(notification.id);
            }
            _handleNotificationTap(context, notification);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: notification.isRead
                  ? Border.all(color: const Color(0xFFE2E8F0), width: 1)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return Icons.calendar_today_rounded;
      case 'PAYMENT':
        return Icons.payment_rounded;
      case 'PAYMENT_SUCCESS':
        return Icons.check_circle_rounded;
      case 'PAYMENT_FAILED':
        return Icons.cancel_rounded;
      case 'THERAPY':
      case 'THERAPY_UPDATE':
        return Icons.medical_services_rounded;
      case 'REPORT':
      case 'LAPORAN_BARU':
        return Icons.description_rounded;
      case 'MESSAGE':
        return Icons.chat_bubble_rounded;
      case 'GAME':
        return Icons.games_rounded;
      case 'PROGRESS_UPLOAD':
        return Icons.cloud_upload_rounded;
      case 'ARTIKULASI_REVIEW':
        return Icons.mic_rounded;
      case 'SESSION_REMINDER':
        return Icons.alarm_rounded;
      case 'ADMIN_THERAPIST_REGISTRATION':
        return Icons.person_add_alt_1_rounded;
      case 'ADMIN_PAYMENT_SUCCESS':
        return Icons.check_circle_rounded;
      case 'ADMIN_PAYMENT_FAILED':
        return Icons.cancel_rounded;
      case 'ADMIN_NEW_REPORT':
        return Icons.description_rounded;
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        return Icons.warning_amber_rounded;
      case 'ADMIN_NEW_BOOKING':
        return Icons.calendar_month_rounded;
      case 'ADMIN_SESSION_COMPLETED':
        return Icons.task_alt_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return const Color(0xFF3B82F6);
      case 'PAYMENT':
        return const Color(0xFF10B981);
      case 'PAYMENT_SUCCESS':
        return const Color(0xFF10B981);
      case 'PAYMENT_FAILED':
        return const Color(0xFFEF4444);
      case 'THERAPY':
      case 'THERAPY_UPDATE':
        return const Color(0xFF8B5CF6);
      case 'REPORT':
      case 'LAPORAN_BARU':
        return const Color(0xFFF59E0B);
      case 'MESSAGE':
        return const Color(0xFF06B6D4);
      case 'GAME':
        return const Color(0xFFEC4899);
      case 'PROGRESS_UPLOAD':
        return const Color(0xFF3B82F6);
      case 'ARTIKULASI_REVIEW':
        return const Color(0xFF10B981);
      case 'SESSION_REMINDER':
        return const Color(0xFF3B82F6);
      case 'ADMIN_THERAPIST_REGISTRATION':
        return const Color(0xFF10B981);
      case 'ADMIN_PAYMENT_SUCCESS':
        return const Color(0xFF10B981);
      case 'ADMIN_PAYMENT_FAILED':
        return const Color(0xFFEF4444);
      case 'ADMIN_NEW_REPORT':
        return const Color(0xFFF59E0B);
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        return const Color(0xFFEF4444);
      case 'ADMIN_NEW_BOOKING':
        return const Color(0xFF3B82F6);
      case 'ADMIN_SESSION_COMPLETED':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    switch (notification.type.toUpperCase()) {
      case 'BOOKING':
        // Navigate to therapy schedule detail if sessionId available
        if (notification.sessionId != null) {
          // Navigate to therapist schedule page with session
          context.push('/therapist/jadwal');
        } else if (notification.childId != null) {
          context.push('/therapist/pasien/${notification.childId}');
        } else {
          context.push('/therapist/jadwal');
        }
        break;
      case 'PAYMENT':
      case 'PAYMENT_SUCCESS':
      case 'PAYMENT_FAILED':
        context.push('/pembayaran');
        break;
      case 'REPORT':
      case 'LAPORAN_BARU':
        context.push('/laporan');
        break;
      case 'GAME':
        context.push('/game');
        break;
      case 'THERAPY':
      case 'THERAPY_UPDATE':
        context.push('/dashboard');
        break;
      case 'PROGRESS_UPLOAD':
        // Navigate to patient detail with progress tab
        if (notification.childId != null) {
          context.push('/therapist/pasien/${notification.childId}', extra: {'openTab': 'progress'});
        } else {
          context.push('/therapist/pasien');
        }
        break;
      case 'ARTIKULASI_REVIEW':
        context.push('/game');
        break;
      case 'SESSION_REMINDER':
        context.push('/therapist/jadwal');
        break;
      case 'ADMIN_THERAPIST_REGISTRATION':
        context.push('/admin/users');
        break;
      case 'ADMIN_PAYMENT_SUCCESS':
      case 'ADMIN_PAYMENT_FAILED':
        context.push('/admin/pembayaran');
        break;
      case 'ADMIN_NEW_REPORT':
        context.push('/admin/laporan');
        break;
      case 'ADMIN_HIGH_RISK_DIAGNOSIS':
        context.push('/diagnosa');
        break;
      case 'ADMIN_NEW_BOOKING':
        context.push('/jadwal');
        break;
      case 'ADMIN_SESSION_COMPLETED':
        context.push('/admin-dashboard');
        break;
      default:
        break;
    }
  }
}