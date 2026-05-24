import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';
import 'storage_service.dart';

class WebSocketService {
  IO.Socket? _socket;
  
  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Stream controllers
  final _connectionStateController = StreamController<bool>.broadcast();
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get notifications => _notificationStreamController.stream;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = StorageService.getString(AppConstants.tokenKey);
    if (token == null) {
      print('[WebSocket] Cannot connect: No auth token found');
      return;
    }

    print('[WebSocket] Connecting to ${AppConstants.wsUrl}...');
    
    _socket = IO.io(AppConstants.wsUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build()
    );

    _setupEventListeners();
    _socket?.connect();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      print('[WebSocket] Connected');
      _connectionStateController.add(true);
      
      // Update presence
      _socket?.emit('presence', 'online');
    });

    _socket?.onDisconnect((_) {
      print('[WebSocket] Disconnected');
      _connectionStateController.add(false);
    });

    _socket?.onConnectError((err) {
      print('[WebSocket] Connection Error: $err');
      _connectionStateController.add(false);
    });

    _socket?.onError((err) {
      print('[WebSocket] Error: $err');
    });

    _socket?.on('notification', (data) {
      print('[WebSocket] Received notification: $data');
      if (data is Map) {
        _notificationStreamController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void disconnect() {
    if (_socket != null) {
      print('[WebSocket] Disconnecting...');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _connectionStateController.add(false);
    }
  }

  // Example functions to emit and listen
  void joinTherapyRoom(String therapyId) {
    if (isConnected) {
      _socket?.emit('join_therapy', therapyId);
    }
  }

  void leaveTherapyRoom(String therapyId) {
    if (isConnected) {
      _socket?.emit('leave_therapy', therapyId);
    }
  }
}
