import 'package:flutter/material.dart';

/// App Constants
/// Berisi konstanta-konstanta aplikasi seperti URL API, konfigurasi, dll
class AppConstants {
  // API Configuration
  /// Override in development using:
  /// flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
  /// For Android emulator, use: http://10.0.2.2:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://talkio-backend.vercel.app/api',
  );

  /// Override in development using:
  /// flutter run --dart-define=WS_BASE_URL=http://localhost:3000
  static const String wsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'https://talkio-backend.vercel.app',
  );

  static const String midtransBaseUrl = 'https://app.sandbox.midtrans.com/snap/v1';

  // Midtrans Configuration
  static const String midtransClientKey = 'SB-Mid-client-YOUR_CLIENT_KEY';
  static const String midtransServerKey = 'SB-Mid-server-YOUR_SERVER_KEY';

  // App Configuration
  static const String appName = 'Terapi Wicara';
  static const String appVersion = '1.0.0';

  // Premier Blue Color Palette - Warna Utama Aplikasi
  static const Color primaryBlue = Color(0xFF0066CC);      // Premier Blue
  static const Color darkBlue = Color(0xFF004C99);         // Darker Blue
  static const Color lightBlue = Color(0xFF3399FF);        // Lighter Blue
  static const Color accentBlue = Color(0xFF0080FF);       // Accent Blue
  static const Color backgroundBlue = Color(0xFFF0F7FF);   // Very Light Blue BG
  
  // Additional Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFEF4444);
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFFB74D);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color infoCyan = Color(0xFF29B6F6);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String useMockDataKey = 'use_mock_data';

  // Mock Mode Configuration
  static const bool defaultMockMode = false; // Default false - use real API
  
  // Role Types - matching backend API values
  static const String roleOrangTua = 'PARENT';
  static const String roleTerapis = 'THERAPIST';
  static const String roleAdmin = 'ADMIN';
  
  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  
  // Therapy Session Status
  static const String sessionScheduled = 'scheduled';
  static const String sessionOngoing = 'ongoing';
  static const String sessionCompleted = 'completed';
  static const String sessionCancelled = 'cancelled';
}