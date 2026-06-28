import '../mock_config.dart';

/// Konsultasi Mock Handler
/// Handler untuk mock API konsultasi
class KonsultasiMockHandler {
  static final MockConfig _mockConfig = MockConfig();
  static List<Map<String, dynamic>> _konsultasiList = [];

  /// Initialize mock data
  static Future<void> _initData() async {
    if (_konsultasiList.isEmpty) {
      final mockData = await _mockConfig.loadMockData('konsultasi_mock.json');
      final data = mockData['data'] as List;
      _konsultasiList = data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  /// Get konsultasi by parent ID
  static Future<MockResponse> getByParent(String parentId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _konsultasiList
          .where((k) => k['parent_id'] == parentId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': filtered.isEmpty 
            ? 'Belum ada riwayat konsultasi' 
            : 'Riwayat konsultasi berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get konsultasi by anak ID
  static Future<MockResponse> getByAnak(String anakId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _konsultasiList
          .where((k) => k['anak_id'] == anakId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': 'Konsultasi per anak berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get konsultasi by terapis ID
  static Future<MockResponse> getByTerapis(String terapisId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _konsultasiList
          .where((k) => k['terapis_id'] == terapisId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': 'Konsultasi pasien berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get konsultasi by ID
  static Future<MockResponse> getById(String konsultasiId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final konsultasi = _konsultasiList.firstWhere(
        (k) => k['id'] == konsultasiId,
        orElse: () => {},
      );

      if (konsultasi.isEmpty) {
        return MockResponse.error(
          'Data konsultasi tidak ditemukan',
          statusCode: 404,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Detail konsultasi berhasil diambil',
        'data': konsultasi,
      });
    });
  }

  /// Create new konsultasi
  static Future<MockResponse> create(Map<String, dynamic> konsultasiData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      // Validation
      if (!konsultasiData.containsKey('parent_id') || konsultasiData['parent_id'].toString().isEmpty) {
        return MockResponse.error(
          'ID parent harus diisi',
          statusCode: 400,
        );
      }

      if (!konsultasiData.containsKey('subject') || konsultasiData['subject'].toString().isEmpty) {
        return MockResponse.error(
          'Subjek konsultasi harus diisi',
          statusCode: 400,
        );
      }

      if (!konsultasiData.containsKey('message') || konsultasiData['message'].toString().isEmpty) {
        return MockResponse.error(
          'Pesan konsultasi harus diisi',
          statusCode: 400,
        );
      }

      // Create new konsultasi
      final newKonsultasi = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'parent_id': konsultasiData['parent_id'],
        'anak_id': konsultasiData['anak_id'] ?? null,
        'terapis_id': konsultasiData['terapis_id'] ?? null,
        'category': konsultasiData['category'] ?? 'Konsultasi Umum',
        'subject': konsultasiData['subject'],
        'message': konsultasiData['message'],
        'status': 'pending',
        'response': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _konsultasiList.add(newKonsultasi);

      return MockResponse.success({
        'success': true,
        'message': 'Konsultasi berhasil dibuat',
        'data': newKonsultasi,
      }, statusCode: 201);
    });
  }

  /// Update response terapis
  static Future<MockResponse> updateResponse(String konsultasiId, String response) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _konsultasiList.indexWhere((k) => k['id'] == konsultasiId);

      if (index == -1) {
        return MockResponse.error(
          'Data konsultasi tidak ditemukan',
          statusCode: 404,
        );
      }

      _konsultasiList[index] = {
        ..._konsultasiList[index],
        'response': response,
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Response berhasil ditambahkan',
        'data': _konsultasiList[index],
      });
    });
  }

  /// Update konsultasi
  static Future<MockResponse> update(String konsultasiId, Map<String, dynamic> konsultasiData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _konsultasiList.indexWhere((k) => k['id'] == konsultasiId);

      if (index == -1) {
        return MockResponse.error(
          'Data konsultasi tidak ditemukan',
          statusCode: 404,
        );
      }

      _konsultasiList[index] = {
        ..._konsultasiList[index],
        ...konsultasiData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Konsultasi berhasil diupdate',
        'data': _konsultasiList[index],
      });
    });
  }

  /// Get konsultasi by status
  static Future<MockResponse> getByStatus(String status, {String? terapisId}) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      var filtered = _konsultasiList.where((k) => k['status'] == status).toList();

      if (terapisId != null) {
        filtered = filtered.where((k) => k['terapis_id'] == terapisId).toList();
      }

      return MockResponse.success({
        'success': true,
        'message': 'Data konsultasi berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Clear mock data (for testing)
  static void clearData() {
    _konsultasiList.clear();
  }
}
