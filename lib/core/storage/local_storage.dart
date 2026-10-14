import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  // ==============================
  // String
  // ==============================

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return _preferences.setString(key, value);
  }

  // ==============================
  // Boolean
  // ==============================

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return _preferences.setBool(key, value);
  }

  // ==============================
  // Integer
  // ==============================

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    return _preferences.setInt(key, value);
  }

  // ==============================
  // Double
  // ==============================

  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return _preferences.setDouble(key, value);
  }

  // ==============================
  // Remove
  // ==============================

  Future<bool> remove(String key) async {
    return _preferences.remove(key);
  }

  Future<bool> clear() async {
    return _preferences.clear();
  }

  // ==============================
  // Exists
  // ==============================

  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}
