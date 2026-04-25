import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final StorageService _storage = StorageService();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isStudent => _currentUser?.role == UserRole.student;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize - check saved login
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _storage.getSavedUser();
    } catch (e) {
      debugPrint('Auth init error: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String userId, UserRole role,
      {bool rememberMe = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Admin validation
      if (role == UserRole.admin) {
        if (!SupabaseService.isValidAdminId(userId)) {
          _errorMessage = 'Invalid admin credentials';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = User(
          id: userId.toUpperCase(),
          name: 'Library Admin',
          role: UserRole.admin,
        );
      } else {
        // Student validation: 11-digit ID (e.g., 25101210443)
        if (!SupabaseService.isValidStudentId(userId)) {
          _errorMessage = 'Student ID must be exactly 11 digits';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Check if student exists or create new one in Supabase
        var student = await _supabaseService.getStudent(userId);

        student ??= await _supabaseService.upsertStudent(userId);

        _currentUser = User(
          id: userId,
          name: student?.name ?? 'Student $userId',
          role: UserRole.student,
        );
      }

      await _storage.saveUser(_currentUser!, rememberMe: rememberMe);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearUser();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
