import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../../features/auth/providers/auth_provider.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _apiService;
  final WebSocketService _wsService = WebSocketService();

  NotificationNotifier(this._apiService) : super(NotificationState()) {
    _initWebSocketListener();
  }

  void _initWebSocketListener() {
    _wsService.notifications.listen((data) {
      final notification = NotificationModel.fromJson(data);
      addNotification(notification);
    });
  }

  // Called to add a new notification from WebSocket
  void addNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          final notifications = data
              .map((json) => NotificationModel.fromJson(json))
              .toList();
          state = state.copyWith(notifications: notifications, isLoading: false);
          return;
        }
      }
      state = state.copyWith(error: 'Failed to fetch notifications', isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _apiService.markNotificationAsRead(id);
      if (response.statusCode == 200) {
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        state = state.copyWith(notifications: updatedNotifications);
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      if (response.statusCode == 200) {
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();
        state = state.copyWith(notifications: updatedNotifications);
      }
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final apiService = ApiService();
  final notifier = NotificationNotifier(apiService);
  
  // Fetch automatically when authenticated
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.isAuthenticated) {
      notifier.fetchNotifications();
    }
  });

  // Initial fetch if already authenticated
  final authState = ref.read(authProvider);
  if (authState.isAuthenticated) {
    notifier.fetchNotifications();
  }

  return notifier;
});
