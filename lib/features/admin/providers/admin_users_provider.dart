import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class AdminUsersState {
  final List<Map<String, dynamic>> users;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 0,
  });

  AdminUsersState copyWith({
    List<Map<String, dynamic>>? users,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final ApiService _apiService;

  AdminUsersNotifier(this._apiService) : super(const AdminUsersState());

  Future<void> fetchUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAdminUsers(
        page: page,
        limit: limit,
        role: role,
        search: search,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final responseData = data['data'] as Map<String, dynamic>;
          final users = (responseData['users'] as List<dynamic>)
              .map((u) => u as Map<String, dynamic>)
              .toList();
          final pagination = responseData['pagination'] as Map<String, dynamic>;

          state = state.copyWith(
            users: users,
            total: pagination['total'] ?? 0,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            totalPages: pagination['totalPages'] ?? 0,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          error: 'Gagal memuat data users',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> manageUser({
    required String userId,
    required String action,
    String? reason,
  }) async {
    try {
      final response = await _apiService.manageUser(
        userId: userId,
        action: action,
        reason: reason,
      );
      return response.statusCode == 200;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> resetUserPassword(String userId) async {
    try {
      final response = await _apiService.resetUserPassword(userId: userId);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return data['data']['defaultPassword']?.toString() ?? 'terapi123';
        }
        return 'terapi123';
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ApiService());
});
