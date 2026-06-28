import '../mock_config.dart';

/// Pembayaran Mock Handler
/// Handler untuk mock API pembayaran
class PembayaranMockHandler {
  static final MockConfig _mockConfig = MockConfig();
  static List<Map<String, dynamic>> _pembayaranList = [];

  /// Initialize mock data
  static Future<void> _initData() async {
    if (_pembayaranList.isEmpty) {
      final mockData = await _mockConfig.loadMockData('pembayaran_mock.json');
      final data = mockData['data'] as List;
      _pembayaranList = data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  /// Get pembayaran by user ID
  static Future<MockResponse> getByUser(String userId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _pembayaranList
          .where((p) => p['user_id'] == userId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': filtered.isEmpty 
            ? 'Belum ada riwayat pembayaran' 
            : 'Riwayat pembayaran berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get pembayaran by ID
  static Future<MockResponse> getById(String pembayaranId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final pembayaran = _pembayaranList.firstWhere(
        (p) => p['id'] == pembayaranId,
        orElse: () => {},
      );

      if (pembayaran.isEmpty) {
        return MockResponse.error(
          'Data pembayaran tidak ditemukan',
          statusCode: 404,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Detail pembayaran berhasil diambil',
        'data': pembayaran,
      });
    });
  }

  /// Create new pembayaran
  static Future<MockResponse> create(Map<String, dynamic> pembayaranData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      // Validation
      if (!pembayaranData.containsKey('user_id') || pembayaranData['user_id'].toString().isEmpty) {
        return MockResponse.error(
          'ID user harus diisi',
          statusCode: 400,
        );
      }

      if (!pembayaranData.containsKey('total_amount') || pembayaranData['total_amount'] == null) {
        return MockResponse.error(
          'Total pembayaran harus diisi',
          statusCode: 400,
        );
      }

      // Generate mock snap token for Midtrans
      final snapToken = 'mock-snap-token-${DateTime.now().millisecondsSinceEpoch}';

      // Create new pembayaran
      final newPembayaran = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': pembayaranData['user_id'],
        'anak_id': pembayaranData['anak_id'] ?? null,
        'jadwal_id': pembayaranData['jadwal_id'] ?? null,
        'service_type': pembayaranData['service_type'],
        'service_name': pembayaranData['service_name'],
        'price': pembayaranData['price'],
        'admin_fee': pembayaranData['admin_fee'] ?? 0,
        'total_amount': pembayaranData['total_amount'],
        'payment_method': pembayaranData['payment_method'] ?? null,
        'payment_status': 'pending',
        'payment_date': null,
        'snap_token': snapToken,
        'notes': pembayaranData['notes'] ?? null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _pembayaranList.add(newPembayaran);

      return MockResponse.success({
        'success': true,
        'message': 'Pembayaran berhasil dibuat',
        'data': {
          ...newPembayaran,
          'redirect_url': 'https://app.sandbox.midtrans.com/snap/v2/$snapToken',
        }
      }, statusCode: 201);
    });
  }

  /// Update payment status
  static Future<MockResponse> updateStatus(String pembayaranId, Map<String, dynamic> statusData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _pembayaranList.indexWhere((p) => p['id'] == pembayaranId);

      if (index == -1) {
        return MockResponse.error(
          'Data pembayaran tidak ditemukan',
          statusCode: 404,
        );
      }

      final status = statusData['payment_status'] ?? 'pending';
      final validStatuses = ['pending', 'success', 'failed', 'cancelled'];

      if (!validStatuses.contains(status)) {
        return MockResponse.error(
          'Status pembayaran tidak valid',
          statusCode: 400,
        );
      }

      _pembayaranList[index] = {
        ..._pembayaranList[index],
        'payment_status': status,
        'payment_date': status == 'success' ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Status pembayaran berhasil diupdate',
        'data': _pembayaranList[index],
      });
    });
  }

  /// Update pembayaran
  static Future<MockResponse> update(String pembayaranId, Map<String, dynamic> pembayaranData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _pembayaranList.indexWhere((p) => p['id'] == pembayaranId);

      if (index == -1) {
        return MockResponse.error(
          'Data pembayaran tidak ditemukan',
          statusCode: 404,
        );
      }

      _pembayaranList[index] = {
        ..._pembayaranList[index],
        ...pembayaranData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Pembayaran berhasil diupdate',
        'data': _pembayaranList[index],
      });
    });
  }

  /// Get pembayaran by status
  static Future<MockResponse> getByStatus(String status, {String? userId}) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      var filtered = _pembayaranList.where((p) => p['payment_status'] == status).toList();

      if (userId != null) {
        filtered = filtered.where((p) => p['user_id'] == userId).toList();
      }

      return MockResponse.success({
        'success': true,
        'message': 'Data pembayaran berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Clear mock data (for testing)
  static void clearData() {
    _pembayaranList.clear();
  }
}
