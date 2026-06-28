import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/providers/admin_notification_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class AdminNotificationPage extends ConsumerWidget {
  const AdminNotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminNotificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Notifikasi Admin',
        showBackButton: true,
        showLogo: false,
        showUserMenu: false,
        showNotifications: false,
        actions: [
          if (state.summary.totalUnread > 0)
            TextButton(
              onPressed: () => ref.read(adminNotificationProvider.notifier).markAllAsRead(),
              child: Text(
                'Baca Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationList(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(AdminNotificationState state) {
    final s = state.summary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _buildPriorityChip('HIGH', s.highCount, const Color(0xFFEF4444)),
          const SizedBox(width: 8),
          _buildPriorityChip('MEDIUM', s.mediumCount, const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          _buildPriorityChip('LOW', s.lowCount, const Color(0xFF6B7280)),
          const Spacer(),
          Text(
            '${s.totalUnread} belum dibaca',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
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
          Icon(Icons.notifications_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi admin akan muncul di sini',
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    AdminNotificationState state,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(adminNotificationProvider.notifier).fetchAdminNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
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
    final icon = _getIcon(notification.type);
    final iconColor = _getColor(notification.type);
    final bgColor = iconColor.withValues(alpha: 0.1);
    final priorityColor = _getPriorityColor(notification.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: notification.isRead ? Colors.white : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        elevation: notification.isRead ? 0 : 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (!notification.isRead) {
              await ref.read(adminNotificationProvider.notifier).markAsRead(notification.id);
            }
            _handleTap(context, notification);
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
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.priority,
                              style: GoogleFonts.poppins(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryBlue, shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: const Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
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

  Color _getColor(String type) {
    switch (type.toUpperCase()) {
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return const Color(0xFFEF4444);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _handleTap(BuildContext context, NotificationModel notification) {
    switch (notification.type.toUpperCase()) {
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
