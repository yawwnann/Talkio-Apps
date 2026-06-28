import '../mock_config.dart';

/// Jadwal Mock Handler
/// Handler untuk mock API jadwal terapi
class JadwalMockHandler {
  static final MockConfig _mockConfig = MockConfig();
  static List<Map<String, dynamic>> _jadwalList = [];

  /// Initialize mock data
  static Future<void> _initData() async {
    if (_jadwalList.isEmpty) {
      final mockData = await _mockConfig.loadMockData('jadwal_mock.json');
      final data = mockData['data'] as List;
      _jadwalList = data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  /// Get jadwal by terapis ID
  static Future<MockResponse> getByTerapis(String terapisId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _jadwalList
          .where((j) => j['terapis_id'] == terapisId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': filtered.isEmpty 
            ? 'Tidak ada jadwal' 
            : 'Jadwal terapis berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get jadwal by parent ID
  static Future<MockResponse> getByParent(String parentId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _jadwalList
          .where((j) => j['parent_id'] == parentId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': 'Jadwal berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get jadwal by anak ID
  static Future<MockResponse> getByAnak(String anakId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _jadwalList
          .where((j) => j['anak_id'] == anakId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': 'Riwayat jadwal anak berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get jadwal by ID
  static Future<MockResponse> getById(String jadwalId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final jadwal = _jadwalList.firstWhere(
        (j) => j['id'] == jadwalId,
        orElse: () => {},
      );

      if (jadwal.isEmpty) {
        return MockResponse.error(
          'Jadwal tidak ditemukan',
          statusCode: 404,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Detail jadwal berhasil diambil',
        'data': jadwal,
      });
    });
  }

  /// Create new jadwal
  static Future<MockResponse> create(Map<String, dynamic> jadwalData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      // Validation
      if (!jadwalData.containsKey('anak_id') || jadwalData['anak_id'].toString().isEmpty) {
        return MockResponse.error(
          'ID anak harus diisi',
          statusCode: 400,
        );
      }

      if (!jadwalData.containsKey('date') || jadwalData['date'].toString().isEmpty) {
        return MockResponse.error(
          'Tanggal harus diisi',
          statusCode: 400,
        );
      }

      // Create new jadwal
      final newJadwal = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'anak_id': jadwalData['anak_id'],
        'terapis_id': jadwalData['terapis_id'],
        'parent_id': jadwalData['parent_id'],
        'title': jadwalData['title'],
        'description': jadwalData['description'] ?? null,
        'date': jadwalData['date'],
        'start_time': jadwalData['start_time'],
        'end_time': jadwalData['end_time'],
        'location': jadwalData['location'] ?? null,
        'status': jadwalData['status'] ?? 'scheduled',
        'notes': jadwalData['notes'] ?? null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _jadwalList.add(newJadwal);

      return MockResponse.success({
        'success': true,
        'message': 'Jadwal berhasil ditambahkan',
        'data': newJadwal,
      }, statusCode: 201);
    });
  }

  /// Update jadwal
  static Future<MockResponse> update(String jadwalId, Map<String, dynamic> jadwalData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _jadwalList.indexWhere((j) => j['id'] == jadwalId);

      if (index == -1) {
        return MockResponse.error(
          'Jadwal tidak ditemukan',
          statusCode: 404,
        );
      }

      _jadwalList[index] = {
        ..._jadwalList[index],
        ...jadwalData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Jadwal berhasil diupdate',
        'data': _jadwalList[index],
      });
    });
  }

  /// Delete jadwal
  static Future<MockResponse> delete(String jadwalId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _jadwalList.indexWhere((j) => j['id'] == jadwalId);

      if (index == -1) {
        return MockResponse.error(
          'Jadwal tidak ditemukan',
          statusCode: 404,
        );
      }

      _jadwalList.removeAt(index);

      return MockResponse.success({
        'success': true,
        'message': 'Jadwal berhasil dihapus',
        'data': null,
      });
    });
  }

  /// Get jadwal by date range
  static Future<MockResponse> getByDateRange({
    required String startDate,
    required String endDate,
    String? terapisId,
  }) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      var filtered = _jadwalList.where((j) {
        final jadwalDate = j['date'] as String;
        return jadwalDate.compareTo(startDate) >= 0 && 
               jadwalDate.compareTo(endDate) <= 0;
      }).toList();

      if (terapisId != null) {
        filtered = filtered.where((j) => j['terapis_id'] == terapisId).toList();
      }

      return MockResponse.success({
        'success': true,
        'message': 'Jadwal berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Clear mock data (for testing)
  static void clearData() {
    _jadwalList.clear();
  }
}
