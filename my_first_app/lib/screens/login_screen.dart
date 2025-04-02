import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  ChatUser? _user;
  bool _loading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  ChatUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  ApiService? _apiService;
  ApiService? get apiService => _apiService;

  final _storage = const FlutterSecureStorage();

  AuthProvider() {
    _checkToken();
  }

  // Check if token exists in secure storage
  Future<void> _checkToken() async {
    _loading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        _token = token;
        _apiService = ApiService(token: token);
        await _getUserProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = e.toString();
      await _storage.delete(key: 'token');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.login(username, password);
      _token = token;
      _apiService = ApiService(token: token);

      await _storage.write(key: 'token', value: token);
      await _getUserProfile();

      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String username, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.register(username, email, password);
      _token = token;
      _apiService = ApiService(token: token);

      await _storage.write(key: 'token', value: token);
      await _getUserProfile();

      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Get user profile
  Future<void> _getUserProfile() async {
    if (_apiService == null) return;

    try {
      _user = await _apiService!.getUserProfile();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _isAuthenticated = false;
    _token = null;
    _user = null;
    _apiService = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}