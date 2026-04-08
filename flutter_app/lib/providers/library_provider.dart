import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/library_status.dart';
import '../models/student.dart';
import '../models/scan_log.dart';
import '../models/scan_response.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class LibraryProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  LibraryStatus? _libraryStatus;
  List<Student> _studentsInside = [];
  List<ScanLog> _scanLogs = [];
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  bool _isSystemOnline = false;

  // Getters
  LibraryStatus? get libraryStatus => _libraryStatus;
  List<Student> get studentsInside => _studentsInside;
  List<ScanLog> get scanLogs => _scanLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSystemOnline => _isSystemOnline;

  // Initialize
  Future<void> initialize() async {
    await checkHealth();
    await fetchAllData();
    startAutoRefresh();
  }

  // Check backend health
  Future<void> checkHealth() async {
    _isSystemOnline = await _api.checkHealth();
    notifyListeners();
  }

  // Fetch all data
  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchLibraryStatus(),
        fetchStudentsInside(),
        fetchScanLogs(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch library status
  Future<void> fetchLibraryStatus() async {
    try {
      _libraryStatus = await _api.getLibraryStatus();
      _isSystemOnline = true;
      notifyListeners();
    } catch (e) {
      _isSystemOnline = false;
      _error = 'Failed to fetch library status';
      notifyListeners();
      rethrow;
    }
  }

  // Fetch students inside
  Future<void> fetchStudentsInside() async {
    try {
      _studentsInside = await _api.getStudentsInside();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch students';
      notifyListeners();
      rethrow;
    }
  }

  // Fetch scan logs
  Future<void> fetchScanLogs({String? studentId}) async {
    try {
      _scanLogs = await _api.getScanLogs(studentId: studentId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch scan logs';
      notifyListeners();
      rethrow;
    }
  }

  // Process scan
  Future<ScanResponse> processScan(String studentId) async {
    try {
      final response = await _api.processScan(studentId);
      
      // Refresh data after scan
      await fetchAllData();
      
      return response;
    } catch (e) {
      throw Exception('Scan failed: $e');
    }
  }

  // Reset system (admin only)
  Future<void> resetSystem() async {
    try {
      await _api.resetSystem();
      await fetchAllData();
    } catch (e) {
      throw Exception('Reset failed: $e');
    }
  }

  // Auto-refresh
  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      ApiConfig.refreshInterval,
      (_) => fetchAllData(),
    );
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  // Refresh all data (alias for UI)
  Future<void> refreshData() async {
    await fetchAllData();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
