import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final StorageService _storage = StorageService();
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isStudent => _currentUser?.role == UserRole.student;
  bool get isLoading => _isLoading;

  // Initialize - check saved login
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = await _storage.getSavedUser();
    } catch (e) {
      // Handle error gracefully
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String userId, UserRole role, {bool rememberMe = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simple validation for demo
      if (role == UserRole.admin) {
        if (userId.toUpperCase() != ApiConfig.adminId) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = User(
          id: userId.toUpperCase(),
          name: 'Admin',
          role: UserRole.admin,
        );
      } else {
        // Student validation: STU + 3 digits
        if (!_isValidStudentId(userId)) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = User(
          id: userId.toUpperCase(),
          name: 'Student ${userId.toUpperCase()}',
          role: UserRole.student,
        );
      }

      await _storage.saveUser(_currentUser!, rememberMe: rememberMe);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearUser();
    _currentUser = null;
    notifyListeners();
  }

  // Validate student ID format
  bool _isValidStudentId(String id) {
    // Format: STU001, STU002, etc.
    final regex = RegExp(r'^STU\d{3}$', caseSensitive: false);
    return regex.hasMatch(id);
  }
}
