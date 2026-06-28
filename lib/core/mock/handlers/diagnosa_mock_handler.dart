import '../mock_config.dart';

/// Diagnosa Mock Handler
/// Handler untuk mock API diagnosa
class DiagnosaMockHandler {
  static final MockConfig _mockConfig = MockConfig();
  static List<Map<String, dynamic>> _diagnosaList = [];

  /// Initialize mock data
  static Future<void> _initData() async {
    if (_diagnosaList.isEmpty) {
      final mockData = await _mockConfig.loadMockData('diagnosa_mock.json');
      final data = mockData['data'] as List;
      _diagnosaList = data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  /// Get diagnosa by anak ID
  static Future<MockResponse> getByAnakId(String anakId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _diagnosaList
          .where((d) => d['anak_id'] == anakId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': filtered.isEmpty 
            ? 'Belum ada riwayat diagnosa' 
            : 'Riwayat diagnosa berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get diagnosa by ID
  static Future<MockResponse> getById(String diagnosaId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final diagnosa = _diagnosaList.firstWhere(
        (d) => d['id'] == diagnosaId,
        orElse: () => {},
      );

      if (diagnosa.isEmpty) {
        return MockResponse.error(
          'Data diagnosa tidak ditemukan',
          statusCode: 404,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Detail diagnosa berhasil diambil',
        'data': diagnosa,
      });
    });
  }

  /// Create new diagnosa
  static Future<MockResponse> create(Map<String, dynamic> diagnosaData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      // Validation
      if (!diagnosaData.containsKey('anak_id') || diagnosaData['anak_id'].toString().isEmpty) {
        return MockResponse.error(
          'ID anak harus diisi',
          statusCode: 400,
        );
      }

      if (!diagnosaData.containsKey('diagnosis_code') || diagnosaData['diagnosis_code'].toString().isEmpty) {
        return MockResponse.error(
          'Kode diagnosa harus diisi',
          statusCode: 400,
        );
      }

      // Create new diagnosa
      final newDiagnosa = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'anak_id': diagnosaData['anak_id'],
        'terapis_id': diagnosaData['terapis_id'],
        'konsultasi_id': diagnosaData['konsultasi_id'] ?? null,
        'diagnosis_code': diagnosaData['diagnosis_code'],
        'diagnosis_name': diagnosaData['diagnosis_name'],
        'severity': diagnosaData['severity'] ?? 'ringan',
        'recommendation': diagnosaData['recommendation'],
        'notes': diagnosaData['notes'] ?? null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _diagnosaList.add(newDiagnosa);

      return MockResponse.success({
        'success': true,
        'message': 'Diagnosa berhasil ditambahkan',
        'data': newDiagnosa,
      }, statusCode: 201);
    });
  }

  /// Update diagnosa
  static Future<MockResponse> update(String diagnosaId, Map<String, dynamic> diagnosaData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _diagnosaList.indexWhere((d) => d['id'] == diagnosaId);

      if (index == -1) {
        return MockResponse.error(
          'Data diagnosa tidak ditemukan',
          statusCode: 404,
        );
      }

      _diagnosaList[index] = {
        ..._diagnosaList[index],
        ...diagnosaData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Diagnosa berhasil diupdate',
        'data': _diagnosaList[index],
      });
    });
  }

  /// Clear mock data (for testing)
  static void clearData() {
    _diagnosaList.clear();
  }
}
