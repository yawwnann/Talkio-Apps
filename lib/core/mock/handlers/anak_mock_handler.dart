import 'dart:convert';
import '../mock_config.dart';

/// Anak Mock Handler
/// Handler untuk mock API anak (CRUD operations)
class AnakMockHandler {
  static final MockConfig _mockConfig = MockConfig();
  static List<Map<String, dynamic>> _anakList = [];

  /// Initialize mock data
  static Future<void> _initData() async {
    if (_anakList.isEmpty) {
      final mockData = await _mockConfig.loadMockData('anak_mock.json');
      final data = mockData['data'] as List;
      _anakList = data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  /// Get all anak by parent ID
  static Future<MockResponse> getByParentId(String parentId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final filtered = _anakList
          .where((anak) => anak['parent_id'] == parentId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': filtered.isEmpty 
            ? 'Belum ada data anak' 
            : 'Data anak berhasil diambil',
        'data': filtered,
      });
    });
  }

  /// Get anak by ID
  static Future<MockResponse> getById(String anakId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final anak = _anakList.firstWhere(
        (a) => a['id'] == anakId,
        orElse: () => {},
      );

      if (anak.isEmpty) {
        return MockResponse.error(
          'Data anak tidak ditemukan',
          statusCode: 404,
        );
      }

      return MockResponse.success({
        'success': true,
        'message': 'Detail anak berhasil diambil',
        'data': anak,
      });
    });
  }

  /// Create new anak
  static Future<MockResponse> create(Map<String, dynamic> anakData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      // Validation
      if (!anakData.containsKey('name') || anakData['name'].toString().isEmpty) {
        return MockResponse.error(
          'Nama anak harus diisi',
          statusCode: 400,
        );
      }

      if (!anakData.containsKey('birth_date') || anakData['birth_date'] == null) {
        return MockResponse.error(
          'Tanggal lahir harus diisi',
          statusCode: 400,
        );
      }

      if (!anakData.containsKey('gender') || anakData['gender'].toString().isEmpty) {
        return MockResponse.error(
          'Jenis kelamin harus diisi',
          statusCode: 400,
        );
      }

      // Create new anak
      final newAnak = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'parent_id': anakData['parent_id'],
        'name': anakData['name'],
        'birth_date': anakData['birth_date'],
        'gender': anakData['gender'],
        'medical_history': anakData['medical_history'] ?? null,
        'current_condition': anakData['current_condition'] ?? null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _anakList.add(newAnak);

      return MockResponse.success({
        'success': true,
        'message': 'Data anak berhasil ditambahkan',
        'data': newAnak,
      }, statusCode: 201);
    });
  }

  /// Update anak
  static Future<MockResponse> update(String anakId, Map<String, dynamic> anakData) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _anakList.indexWhere((a) => a['id'] == anakId);

      if (index == -1) {
        return MockResponse.error(
          'Data anak tidak ditemukan',
          statusCode: 404,
        );
      }

      // Update data
      _anakList[index] = {
        ..._anakList[index],
        ...anakData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return MockResponse.success({
        'success': true,
        'message': 'Data anak berhasil diupdate',
        'data': _anakList[index],
      });
    });
  }

  /// Delete anak
  static Future<MockResponse> delete(String anakId) async {
    await _initData();

    return _mockConfig.withDelay(() async {
      final index = _anakList.indexWhere((a) => a['id'] == anakId);

      if (index == -1) {
        return MockResponse.error(
          'Data anak tidak ditemukan',
          statusCode: 404,
        );
      }

      _anakList.removeAt(index);

      return MockResponse.success({
        'success': true,
        'message': 'Data anak berhasil dihapus',
        'data': null,
      });
    });
  }

  /// Get all anak (for therapist)
  static Future<MockResponse> getAll() async {
    await _initData();

    return _mockConfig.withDelay(() async {
      return MockResponse.success({
        'success': true,
        'message': 'Data anak berhasil diambil',
        'data': _anakList,
      });
    });
  }

  /// Clear mock data (for testing)
  static void clearData() {
    _anakList.clear();
  }
}
