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
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState()) {
    _init();
  }

  /// Initialize - check auth status
  Future<void> _init() async {
    await _apiService.initMockConfig();
    await _checkAuthStatus();
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

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(email, password);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Backend format: { status: "success", message: "...", data: { token: "...", user: {...} } }
          // Mock format: { status: "success", data: { token: "...", user: {...} } }
          final responseData = data['data'] as Map<String, dynamic>?;

          if (responseData != null) {
            final token = responseData['token'] as String?;
            final userData = responseData['user'] as Map<String, dynamic>?;

            if (token != null && userData != null) {
              final user = UserModel.fromJson(userData);

              // Save to storage
              await StorageService.setString(AppConstants.tokenKey, token);
              await StorageService.setObject(AppConstants.userKey, user.toJson());

              state = state.copyWith(
                user: user,
                isAuthenticated: true,
                isLoading: false,
              );

              return true;
            }
          }
        }

        final message = data is Map<String, dynamic>
            ? data['message'] ?? 'Login gagal'
            : 'Login gagal';
        state = state.copyWith(error: message, isLoading: false);
        return false;
      } else {
        state = state.copyWith(error: 'Login gagal', isLoading: false);
        return false;
      }
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
    String role = 'PARENT',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final responseData = data['data'] as Map<String, dynamic>?;
          final token = data['token'] as String?;

          if (responseData != null) {
            final user = UserModel.fromJson(responseData);

            // If token is in root level, save it
            if (token != null) {
              await StorageService.setString(AppConstants.tokenKey, token);
            }
            await StorageService.setObject(AppConstants.userKey, user.toJson());

            state = state.copyWith(
              user: user,
              isAuthenticated: true,
              isLoading: false,
            );

            return true;
          }
        }

        final message = data is Map<String, dynamic>
            ? data['message'] ?? 'Registrasi gagal'
            : 'Registrasi gagal';
        state = state.copyWith(error: message, isLoading: false);
        return false;
      } else {
        state = state.copyWith(error: 'Registrasi gagal', isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Call API logout (optional, for cleanup)
      await _apiService.logout();

      // Clear storage
      await StorageService.remove(AppConstants.tokenKey);
      await StorageService.remove(AppConstants.userKey);

      state = const AuthState();
    } catch (e) {
      // Even if API fails, clear local data
      await StorageService.remove(AppConstants.tokenKey);
      await StorageService.remove(AppConstants.userKey);
      state = const AuthState();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Note: Update profile API endpoint would go here
      // For now, just update local storage
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

  /// Toggle mock mode
  Future<void> toggleMockMode(bool enabled) async {
    await _apiService.toggleMockMode(enabled);
  }

  /// Get current mock mode
  bool get useMockData => _apiService.useMockData;

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

/// Mock Mode Provider
final mockModeProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.notifier).useMockData;
});
