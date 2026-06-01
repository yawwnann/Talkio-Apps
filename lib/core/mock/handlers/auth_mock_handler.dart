import 'dart:convert';
import '../mock_config.dart';
import '../../../core/constants/app_constants.dart';

/// Auth Mock Handler
/// Handler untuk mock API auth (login, register, logout)
class AuthMockHandler {
  static final MockConfig _mockConfig = MockConfig();

  /// Login mock
  static Future<MockResponse> login(String email, String password) async {
    return _mockConfig.withDelay(() async {
      final mockData = await _mockConfig.loadMockData('auth_mock.json');
      final endpoints = mockData['endpoints'] as Map<String, dynamic>;
      final loginData = endpoints['login'] as Map<String, dynamic>;

      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        return MockResponse.error(
          'Email dan password harus diisi',
          statusCode: 400,
        );
      }

      // Determine role based on email (same logic as real API)
      String role = AppConstants.roleOrangTua;
      String name = 'User Demo';
      String userId = '1';

      if (email.toLowerCase().contains('terapis')) {
        role = AppConstants.roleTerapis;
        name = 'Dr. Ahmad Santoso';
        userId = '2';
      } else if (email.toLowerCase().contains('admin')) {
        role = AppConstants.roleAdmin;
        name = 'Admin Terapi Wicara';
        userId = '3';
      } else if (email.contains('rizki')) {
        name = 'Bunda Rizki';
        userId = '4';
      }

      // Return success response - matching backend format
      return MockResponse.success({
        'status': 'success',
        'message': 'Login berhasil',
        'data': {
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': userId,
            'email': email,
            'name': name,
            'role': role,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        }
      });
    });
  }

  /// Forgot Password mock
  static Future<MockResponse> forgotPassword({
    required String email,
    String? recoveryPin,
  }) async {
    return _mockConfig.withDelay(() async {
      if (email.isEmpty) {
        return MockResponse.error('Email harus diisi', statusCode: 400);
      }

      // Step 1: just email check
      if (recoveryPin == null) {
        return MockResponse.success({
          'status': 'success',
          'message': 'Email ditemukan.',
          'data': {'email': email, 'name': 'User Demo'},
        });
      }

      // Step 2: verify PIN
      if (recoveryPin != '123456') {
        return MockResponse.error(
          'PIN salah. Hubungi admin via WhatsApp di ${AppConstants.adminWhatsApp} untuk bantuan.',
          statusCode: 400,
        );
      }

      return MockResponse.success({
        'status': 'success',
        'message': 'PIN benar. Silakan reset password.',
        'data': {
          'resetToken': 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
        },
      });
    });
  }

  /// Reset Password mock
  static Future<MockResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _mockConfig.withDelay(() async {
      if (token.isEmpty) {
        return MockResponse.error('Token tidak valid', statusCode: 400);
      }

      if (newPassword.length < 6) {
        return MockResponse.error('Password minimal 6 karakter', statusCode: 400);
      }

      return MockResponse.success({
        'status': 'success',
        'message': 'Password berhasil direset. Silakan login.',
      });
    });
  }

  /// Register mock
  static Future<MockResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = AppConstants.roleOrangTua,
    String? recoveryPin,
  }) async {
    return _mockConfig.withDelay(() async {
      final mockData = await _mockConfig.loadMockData('auth_mock.json');
      final endpoints = mockData['endpoints'] as Map<String, dynamic>;
      final registerData = endpoints['register'] as Map<String, dynamic>;

      // Validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return MockResponse.error(
          'Nama, email, dan password harus diisi',
          statusCode: 400,
        );
      }

      if (password.length < 6) {
        return MockResponse.error(
          'Password minimal 6 karakter',
          statusCode: 400,
        );
      }

      // Check if email already exists (mock check)
      if (email.contains('existing')) {
        return MockResponse.error(
          'Email sudah terdaftar',
          statusCode: 409,
        );
      }

      // Return success response - matching backend format
      return MockResponse.success({
        'status': 'success',
        'message': 'Registrasi berhasil',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': email,
          'name': name,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_token_${DateTime.now().millisecondsSinceEpoch}',
      });
    });
  }

  /// Logout mock
  static Future<MockResponse> logout() async {
    return _mockConfig.withDelay(() async {
      final mockData = await _mockConfig.loadMockData('auth_mock.json');
      final endpoints = mockData['endpoints'] as Map<String, dynamic>;
      final logoutData = endpoints['logout'] as Map<String, dynamic>;

      return MockResponse.success({
        'success': true,
        'message': 'Logout berhasil',
        'data': null,
      });
    });
  }

  /// Get current user mock
  static Future<MockResponse> getCurrentUser(String token) async {
    return _mockConfig.withDelay(() async {
      final mockData = await _mockConfig.loadMockData('auth_mock.json');
      final users = (mockData['data'] as Map)['users'] as List;

      // Mock: always return first user (parent)
      final user = users.firstWhere(
        (u) => u['role'] == 'orang_tua',
        orElse: () => users.first,
      );

      return MockResponse.success({
        'success': true,
        'message': 'User data retrieved',
        'data': user,
      });
    });
  }

  /// Update profile mock
  static Future<MockResponse> updateProfile(Map<String, dynamic> profileData) async {
    return _mockConfig.withDelay(() async {
      // Validate data
      if (!profileData.containsKey('name') || profileData['name'].toString().isEmpty) {
        return MockResponse.error(
          'Nama harus diisi',
          statusCode: 400,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Profil berhasil diupdate',
        'data': {
          ...profileData,
          'updated_at': DateTime.now().toIso8601String(),
        }
      });
    });
  }

  /// Change password mock
  static Future<MockResponse> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _mockConfig.withDelay(() async {
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        return MockResponse.error(
          'Semua field harus diisi',
          statusCode: 400,
        );
      }

      if (newPassword.length < 6) {
        return MockResponse.error(
          'Password baru minimal 6 karakter',
          statusCode: 400,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Password berhasil diubah',
        'data': null,
      });
    });
  }
}
