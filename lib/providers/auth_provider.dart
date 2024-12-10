import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<bool> checkAuth() async {
    if (_isInitialized) return _isAuthenticated;

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        _isAuthenticated = false;
        _isInitialized = true;
        return false;
      }

      final userData = await _apiService.getUser();

      _user = User.fromJson(userData);
      _isAuthenticated = true;
      _isInitialized = true;
      return true;
    } catch (e) {
      await _apiService.clearToken();
      _user = null;
      _isAuthenticated = false;
      _isInitialized = true;
      return false;
    }
  }

  Future<void> login(String username, String password) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.login(username, password);
      _user = User.fromJson(response['data']['user']);
      _isAuthenticated = true;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String username, String password) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.register(email, username, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.logout();
      await _apiService.clearToken();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      final userData = await _apiService.getUser();
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) {
        await logout();
      }
    }
  }
}