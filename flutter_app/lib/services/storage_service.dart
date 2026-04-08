import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class StorageService {
  static const String _keyUser = 'current_user';
  static const String _keyRememberMe = 'remember_me';

  // Save user login
  Future<void> saveUser(User user, {bool rememberMe = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(user.toJson()));
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  // Get saved user
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    
    if (!rememberMe) return null;
    
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    
    return User.fromJson(json.decode(userJson));
  }

  // Clear user (logout)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }
}
