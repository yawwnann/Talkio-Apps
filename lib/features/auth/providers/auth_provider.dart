import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';

/// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(ApiService apiService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = StorageService.getString(AppConstants.tokenKey);
      final userData = StorageService.getObject(AppConstants.userKey);

      if (token != null && userData != null) {
        final user = UserModel.fromJson(userData);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Login with email and password (No validation for testing)
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Determine role based on email for testing
      String role = AppConstants.roleOrangTua;
      String name = 'User Demo';

      if (email.toLowerCase().contains('terapis')) {
        role = AppConstants.roleTerapis;
        name = 'Dr. Terapis Demo';
      } else if (email.toLowerCase().contains('admin')) {
        role = AppConstants.roleAdmin;
        name = 'Admin Demo';
      }

      // Mock user data - accept any email/password
      final userData = {
        'id': '1',
        'email': email.isEmpty ? 'demo@example.com' : email,
        'name': name,
        'phone': '081234567890',
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromJson(userData);
      const token = 'mock_token_123';

      // Save to storage
      await StorageService.setString(AppConstants.tokenKey, token);
      await StorageService.setObject(AppConstants.userKey, userData);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = AppConstants.roleOrangTua,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromJson(userData);
      const token = 'mock_token_123';

      // Save to storage
      await StorageService.setString(AppConstants.tokenKey, token);
      await StorageService.setObject(AppConstants.userKey, userData);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Clear storage
      await StorageService.remove(AppConstants.tokenKey);
      await StorageService.remove(AppConstants.userKey);

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Mock API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));

      // Save to storage
      await StorageService.setObject(
        AppConstants.userKey,
        updatedUser.toJson(),
      );

      state = state.copyWith(user: updatedUser, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth Provider Instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});

/// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
