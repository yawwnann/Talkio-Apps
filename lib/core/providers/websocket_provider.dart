import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../services/websocket_service.dart';

/// State class for WebSocket connection
class WebSocketState {
  final bool isConnected;

  const WebSocketState({
    this.isConnected = false,
  });

  WebSocketState copyWith({
    bool? isConnected,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// Notifier to manage WebSocket connection based on Auth state
class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final WebSocketService _wsService = WebSocketService();
  final Ref ref;

  WebSocketNotifier(this.ref) : super(const WebSocketState()) {
    _init();
  }

  void _init() {
    // Listen to WebSocket service connection state
    _wsService.connectionState.listen((isConnected) {
      if (mounted) {
        state = state.copyWith(isConnected: isConnected);
      }
    });

    // Listen to Auth State to connect/disconnect automatically
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        _wsService.connect();
      } else {
        _wsService.disconnect();
      }
    });

    // Initial check if already authenticated
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      _wsService.connect();
    }
  }

  void connect() {
    _wsService.connect();
  }

  void disconnect() {
    _wsService.disconnect();
  }
}

/// Provider instance
final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  return WebSocketNotifier(ref);
});
