import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Secure Storage for sensitive data
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  static Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: _userKey, value: userData);
  }

  static Future<String?> getUserData() async {
    return await _secureStorage.read(key: _userKey);
  }

  static Future<void> deleteUserData() async {
    await _secureStorage.delete(key: _userKey);
  }

  // Hive for caching
  static Future<void> cacheTasks(List<Map<String, dynamic>> tasks) async {
    final box = Hive.box('app_cache');
    await box.put('tasks', tasks);
  }

  static List<Map<String, dynamic>>? getCachedTasks() {
    final box = Hive.box('app_cache');
    final cached = box.get('tasks');
    if (cached is List) {
      return cached.cast<Map<String, dynamic>>();
    }
    return null;
  }

  static Future<void> clearCache() async {
    final box = Hive.box('app_cache');
    await box.clear();
  }
}
