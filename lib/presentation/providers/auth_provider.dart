import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password are required';
      }

      if (!email.contains('@')) {
        throw 'Please enter a valid email';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      _user = await _authRepository.login(email, password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw 'All fields are required';
      }

      if (!email.contains('@')) {
        throw 'Please enter a valid email';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      _user = await _authRepository.register(name, email, password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
