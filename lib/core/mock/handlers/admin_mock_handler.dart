import '../../mock/mock_config.dart';

/// Admin Mock Handler
/// Handle mock data untuk admin endpoints
class AdminMockHandler {
  /// Get Admin Users
  static Future<MockResponse> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock users data
    final List<Map<String, dynamic>> allUsers = [
      {
        'id': 'user-1',
        'name': 'Sarah Wijaya',
        'email': 'sarah@example.com',
        'role': 'THERAPIST',
        'isActive': true,
        'createdAt': '2026-01-15T08:00:00Z',
      },
      {
        'id': 'user-2',
        'name': 'Ahmad Fauzi',
        'email': 'ahmad@example.com',
        'role': 'THERAPIST',
        'isActive': true,
        'createdAt': '2026-02-01T09:00:00Z',
      },
      {
        'id': 'user-3',
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'role': 'PARENT',
        'isActive': true,
        'createdAt': '2026-02-10T10:00:00Z',
      },
      {
        'id': 'user-4',
        'name': 'Lisa Permata',
        'email': 'lisa@example.com',
        'role': 'PARENT',
        'isActive': false,
        'createdAt': '2026-02-15T11:00:00Z',
      },
      {
        'id': 'user-5',
        'name': 'Dewi Lestari',
        'email': 'dewi@example.com',
        'role': 'THERAPIST',
        'isActive': true,
        'createdAt': '2026-03-01T12:00:00Z',
      },
    ];

    // Apply filters
    var filteredUsers = allUsers.where((user) {
      if (role != null && role.isNotEmpty) {
        if (user['role'] != role) return false;
      }
      if (search != null && search.isNotEmpty) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        if (!name.contains(search.toLowerCase()) && !email.contains(search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedUsers = filteredUsers.length > startIndex
        ? filteredUsers.sublist(
            startIndex,
            filteredUsers.length > endIndex ? endIndex : filteredUsers.length,
          )
        : <Map<String, dynamic>>[];

    return MockResponse.success({
      'users': paginatedUsers,
      'pagination': {
        'total': filteredUsers.length,
        'page': page,
        'limit': limit,
        'totalPages': (filteredUsers.length / limit).ceil(),
      },
    });
  }

  /// Manage User (Block/Unblock/Delete)
  static Future<MockResponse> manageUser({
    required String userId,
    required String action,
    String? reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('📦 [MOCK] Admin manage user: $userId, action: $action');
    return MockResponse.success({
      'message': 'User $action successfully',
      'data': {'userId': userId, 'action': action, 'reason': reason},
    });
  }

  /// Reset User Password
  static Future<MockResponse> resetUserPassword({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('📦 [MOCK] Admin reset user password: $userId');
    return MockResponse.success({
      'message': 'Password reset successfully',
      'data': {'userId': userId, 'defaultPassword': 'terapi123'},
    });
  }

  /// Create Admin User (Therapist)
  static Future<MockResponse> createUser({
    required String name,
    required String email,
    required String password,
    String role = 'THERAPIST',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('📦 [MOCK] Admin create user: $email');
    return MockResponse.success({
      'message': 'User created successfully',
      'data': {
        'id': 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'role': role,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Reset User PIN
  static Future<MockResponse> resetUserPin({
    required String userId,
    required String recoveryPin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('📦 [MOCK] Admin reset user PIN: $userId');
    return MockResponse.success({
      'message': 'Recovery PIN reset successfully',
      'data': {'userId': userId, 'recoveryPin': recoveryPin},
    });
  }
}
