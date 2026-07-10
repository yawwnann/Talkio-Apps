import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service
/// Service untuk handle local storage menggunakan SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Save string value
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  // Get string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  // Save int value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }
  
  // Get int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  // Save bool value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  // Get bool value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  // Save double value
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }
  
  // Get double value
  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }
  
  // Save object as JSON string
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }
  
  // Get object from JSON string
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Remove value by key
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  // Clear all stored values
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
  
  // Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
  
  // Get all keys
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}