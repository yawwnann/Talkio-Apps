import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../../features/auth/providers/auth_provider.dart';

class AdminNotificationSummary {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int totalUnread;
  final Map<String, int> eventCounts;

  const AdminNotificationSummary({
    this.highCount = 0,
    this.mediumCount = 0,
    this.lowCount = 0,
    this.totalUnread = 0,
    this.eventCounts = const {},
  });
}

class AdminNotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final AdminNotificationSummary summary;

  const AdminNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.summary = const AdminNotificationSummary(),
  });

  AdminNotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    AdminNotificationSummary? summary,
  }) {
    return AdminNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      summary: summary ?? this.summary,
    );
  }
}

class AdminNotificationNotifier extends StateNotifier<AdminNotificationState> {
  final ApiService _apiService;
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  AdminNotificationNotifier(this._apiService) : super(const AdminNotificationState()) {
    _initWebSocketListener();
  }

  void _initWebSocketListener() {
    _wsSubscription = _wsService.notifications.listen((data) {
      final notification = NotificationModel.fromJson(data);
      if (AdminNotificationType.isAdminType(notification.type)) {
        _addNotification(notification);
      }
    });
  }

  void _addNotification(NotificationModel notification) {
    final updated = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updated,
      summary: _computeSummary(updated),
    );
  }

  AdminNotificationSummary _computeSummary(List<NotificationModel> notifications) {
    int high = 0, medium = 0, low = 0, totalUnread = 0;
    final eventCounts = <String, int>{};

    for (final n in notifications) {
      if (!n.isRead) {
        totalUnread++;
        switch (n.priority) {
          case 'HIGH':
            high++;
          case 'MEDIUM':
            medium++;
          default:
            low++;
        }
      }
      eventCounts.update(n.type, (v) => v + 1, ifAbsent: () => 1);
    }

    return AdminNotificationSummary(
      highCount: high,
      mediumCount: medium,
      lowCount: low,
      totalUnread: totalUnread,
      eventCounts: eventCounts,
    );
  }

  Future<void> fetchAdminNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getAdminNotifications();
      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          final notifications = data
              .map((json) => NotificationModel.fromJson(json))
              .where((n) => AdminNotificationType.isAdminType(n.type))
              .toList();
          state = state.copyWith(
            notifications: notifications,
            isLoading: false,
            summary: _computeSummary(notifications),
          );
          return;
        }
      }
      state = state.copyWith(error: 'Gagal memuat notifikasi admin', isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _apiService.markNotificationAsRead(id);
      if (response.statusCode == 200) {
        final updated = state.notifications.map((n) {
          if (n.id == id) return n.copyWith(isRead: true);
          return n;
        }).toList();
        state = state.copyWith(
          notifications: updated,
          summary: _computeSummary(updated),
        );
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllAdminNotificationsRead();
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(
        notifications: updated,
        summary: _computeSummary(updated),
      );
    } catch (e) {
      print('Failed to mark all as read: $e');
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}

final adminNotificationProvider = StateNotifierProvider<AdminNotificationNotifier, AdminNotificationState>((ref) {
  final apiService = ApiService();
  final notifier = AdminNotificationNotifier(apiService);

  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.isAuthenticated) {
      notifier.fetchAdminNotifications();
    }
  });

  final authState = ref.read(authProvider);
  if (authState.isAuthenticated) {
    notifier.fetchAdminNotifications();
  }

  return notifier;
});
