import 'dart:convert';
import 'package:flutter/services.dart';
import '../mock_config.dart';

class LaporanMockHandler {
  static const String _mockDataPath = 'lib/core/mock/data/laporan_mock.json';
  static List<Map<String, dynamic>> _laporan = [];
  static bool _isLoaded = false;
  static final _mockConfig = MockConfig();

  LaporanMockHandler._();

  static Future<void> _init() async {
    if (_isLoaded) return;
    try {
      final String response = await rootBundle.loadString(_mockDataPath);
      final List<dynamic> data = json.decode(response);
      _laporan = List<Map<String, dynamic>>.from(data);
      _isLoaded = true;
    } catch (e) {
      // Ignore
    }
  }

  static Future<MockResponse> getLaporanByTerapis(String terapisId) async {
    await _init();

    return _mockConfig.withDelay(() async {
      final List<Map<String, dynamic>> filteredLaporan = _laporan
          .where((laporan) => laporan['terapis_id'] == terapisId)
          .toList();

      return MockResponse.success({
        'success': true,
        'message': 'Data laporan berhasil diambil',
        'data': filteredLaporan,
      });
    });
  }
}
