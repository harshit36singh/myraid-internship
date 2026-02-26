import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<User> login(String email, String password) async {
    try {
      // Mock authentication - using JSONPlaceholder
      final response = await _apiService.get('/users/1');
      final userData = response.data;
      
      final user = User(
        id: userData['id'].toString(),
        name: userData['name'],
        email: email,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Save token and user data
      await StorageService.saveToken(user.token!);
      await StorageService.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      // Mock registration
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      await StorageService.saveToken(user.token!);
      await StorageService.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    await StorageService.deleteUserData();
    await StorageService.clearCache();
  }
}
