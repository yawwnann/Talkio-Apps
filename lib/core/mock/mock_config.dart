import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_constants.dart';

/// Mock Configuration
/// Singleton class untuk mengelola toggle antara mock data dan real API
class MockConfig {
  static final MockConfig _instance = MockConfig._internal();
  
  factory MockConfig() => _instance;
  
  MockConfig._internal();

  // Storage key untuk mock toggle
  static const String _mockToggleKey = 'use_mock_data';
  
  // Default value
  bool _useMockData = false;
  
  // Cache untuk mock data
  final Map<String, dynamic> _mockDataCache = {};

  /// Get current mock mode
  bool get useMockData => _useMockData;

  /// Set mock mode
  Future<void> setMockMode(bool enabled) async {
    _useMockData = enabled;
    await StorageService.setBool(_mockToggleKey, enabled);
    print('🔄 Mock Mode: ${enabled ? 'ON (Mock Data)' : 'OFF (Real API)'}');
  }

  /// Initialize mock config - load saved preference
  Future<void> init() async {
    try {
      final savedMode = StorageService.getBool(_mockToggleKey);
      _useMockData = savedMode ?? AppConstants.defaultMockMode;
      print('📦 Mock Config initialized: ${_useMockData ? 'Mock Data' : 'Real API'}');
    } catch (e) {
      _useMockData = AppConstants.defaultMockMode;
      print('⚠️ Mock Config init error: $e');
    }
  }

  /// Load mock data from JSON file
  Future<Map<String, dynamic>> loadMockData(String fileName) async {
    // Check cache first
    if (_mockDataCache.containsKey(fileName)) {
      return _mockDataCache[fileName] as Map<String, dynamic>;
    }

    try {
      // Load from assets
      final jsonString = await rootBundle.loadString('lib/core/mock/data/$fileName');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Cache the data
      _mockDataCache[fileName] = data;
      
      return data;
    } catch (e) {
      print('❌ Error loading mock data ($fileName): $e');
      return {};
    }
  }

  /// Load mock data from string (for handlers)
  Future<String> loadMockDataString(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString('lib/core/mock/data/$fileName');
      return jsonString;
    } catch (e) {
      print('❌ Error loading mock data string ($fileName): $e');
      return '[]';
    }
  }

  /// Clear cache (useful for testing)
  void clearCache() {
    _mockDataCache.clear();
    print('🗑️ Mock data cache cleared');
  }

  /// Get mock data for specific endpoint
  Future<dynamic> getEndpointData(String module, String endpoint) async {
    final data = await loadMockData('${module}_mock.json');
    
    // Navigate through nested structure if needed
    if (data.containsKey('endpoints') && 
        data['endpoints'] is Map && 
        data['endpoints'].containsKey(endpoint)) {
      return data['endpoints'][endpoint];
    }
    
    // Return full data if no specific endpoint
    return data;
  }

  /// Simulate network delay
  Future<T> withDelay<T>(Future<T> Function() operation, {int ms = 800}) async {
    await Future.delayed(Duration(milliseconds: ms));
    return await operation();
  }

  /// Simulate different network conditions
  Future<void> simulateNetworkCondition({bool slow = false, bool error = false}) async {
    if (error) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Network error simulated');
    }
    
    if (slow) {
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}

/// Mock Response class - meniru Response dari Dio
class MockResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, dynamic> headers;

  MockResponse({
    this.statusCode = 200,
    required this.data,
    this.headers = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data,
      'headers': headers,
    };
  }

  static MockResponse success(dynamic data, {int statusCode = 200}) {
    return MockResponse(
      statusCode: statusCode,
      data: data,
      headers: {'content-type': 'application/json'},
    );
  }

  static MockResponse error(String message, {int statusCode = 400}) {
    return MockResponse(
      statusCode: statusCode,
      data: {
        'success': false,
        'message': message,
      },
      headers: {'content-type': 'application/json'},
    );
  }
}
