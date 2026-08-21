import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/library_status.dart';
import '../models/student.dart';
import '../models/scan_log.dart';
import '../models/scan_response.dart';
import '../models/seat_map.dart';
import '../services/supabase_service.dart';

class LibraryProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();

  LibraryStatus? _libraryStatus;
  List<Student> _studentsInside = [];
  List<ScanLog> _scanLogs = [];
  List<ScanLog> _studentScanLogs = []; // Logs for current logged-in student
  SeatMap? _seatMap;
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  bool _isSystemOnline = true;
  DateTime? _lastSync;

  // Real-time subscriptions
  RealtimeChannel? _statusChannel;
  RealtimeChannel? _logsChannel;

  // Getters
  LibraryStatus? get libraryStatus => _libraryStatus;
  List<Student> get studentsInside => _studentsInside;
  List<ScanLog> get scanLogs => _scanLogs;
  List<ScanLog> get studentScanLogs => _studentScanLogs;
  SeatMap? get seatMap => _seatMap;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSystemOnline => _isSystemOnline;
  String? get lastSyncTime =>
      _lastSync != null ? DateFormat('MMM d, h:mm a').format(_lastSync!) : null;

  // Sync library status from ground truth (_studentsInside)
  void _syncLibraryStatus() {
    final totalSeats = _libraryStatus?.totalSeats ?? 100;
    final occupiedSeats = _studentsInside.length;
    final availableSeats = totalSeats - occupiedSeats;
    final occupancyPercentage =
        totalSeats > 0 ? (occupiedSeats / totalSeats) * 100 : 0.0;

    _libraryStatus = LibraryStatus(
      totalSeats: totalSeats,
      occupiedSeats: occupiedSeats,
      availableSeats: availableSeats,
      occupancyPercentage: occupancyPercentage,
    );

    debugPrint(
        '[LibraryProvider] _syncLibraryStatus -> studentsInside: $occupiedSeats, available: $availableSeats, occupancy: ${occupancyPercentage.toStringAsFixed(1)}%');
  }

  // Initialize
  Future<void> initialize({String? studentId}) async {
    await fetchAllData(studentId: studentId);
    startAutoRefresh(studentId: studentId);
    _setupRealtimeSubscriptions();
  }

  // Setup real-time subscriptions
  void _setupRealtimeSubscriptions() {
    try {
      _statusChannel = _supabase.subscribeToLibraryStatus((payload) {
        debugPrint('Library status changed: $payload');
        fetchLibraryStatus();
        fetchSeatMap();
      });

      _logsChannel = _supabase.subscribeToScanLogs((payload) {
        debugPrint('New scan log: $payload');
        fetchScanLogs();
        fetchStudentsInside();
      });
    } catch (e) {
      debugPrint('Error setting up realtime: $e');
    }
  }

  // Fetch all data
  Future<void> fetchAllData({String? studentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchLibraryStatus(),
        fetchStudentsInside(),
        fetchScanLogs(),
        fetchSeatMap(),
        if (studentId != null) fetchStudentScanLogs(studentId),
      ]);
      _isSystemOnline = true;
      _lastSync = DateTime.now();
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch all data error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch library status
  Future<void> fetchLibraryStatus() async {
    try {
      _libraryStatus = await _supabase.getLibraryStatus();
      _syncLibraryStatus(); // Ensure status matches ground truth
      _isSystemOnline = true;
      notifyListeners();
    } catch (e) {
      _isSystemOnline = false;
      _error = 'Failed to fetch library status';
      debugPrint('Fetch status error: $e');
      notifyListeners();
    }
  }

  // Fetch students inside
  Future<void> fetchStudentsInside() async {
    try {
      _studentsInside = await _supabase.getStudentsInside();
      _syncLibraryStatus(); // Recalculate status from ground truth
      debugPrint(
          '[LibraryProvider] fetchStudentsInside -> count: ${_studentsInside.length}');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch students';
      debugPrint('Fetch students error: $e');
      notifyListeners();
    }
  }

  // Fetch scan logs (all logs - for admin)
  Future<void> fetchScanLogs() async {
    try {
      _scanLogs = await _supabase.getScanLogs(limit: 50);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch scan logs';
      debugPrint('Fetch logs error: $e');
      notifyListeners();
    }
  }

  // Fetch scan logs for specific student
  Future<void> fetchStudentScanLogs(String studentId) async {
    try {
      _studentScanLogs =
          await _supabase.getStudentScanLogs(studentId, limit: 50);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch student scan logs';
      debugPrint('Fetch student logs error: $e');
      notifyListeners();
    }
  }

  // Process scan
  Future<ScanResponse> processScan(String studentId) async {
    try {
      final result = await _supabase.processScan(studentId);

      if (result['success'] == true) {
        // Refresh data after scan
        await fetchAllData(studentId: studentId);

        final student = Student(
          id: result['studentId'] ?? studentId,
          name: 'Student ${result['studentId'] ?? studentId}',
          currentStatus: result['newStatus'] ?? 'UNKNOWN',
          scanCount: 0,
        );

        return ScanResponse(
          success: true,
          action: result['action'] ?? 'UNKNOWN',
          student: student,
          libraryStatus: _libraryStatus ??
              LibraryStatus(
                totalSeats: 100,
                occupiedSeats: 0,
                availableSeats: 100,
                occupancyPercentage: 0,
              ),
        );
      } else {
        final errorMsg = result['error']?.toString() ?? 'Scan failed';
        if (errorMsg.contains('42501') || errorMsg.contains('row-level security')) {
          throw Exception('Unable to register new student. Database security policy (RLS) restricts student creation.');
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Scan error: $e');
      if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
        throw Exception('Unable to register new student. Database security policy (RLS) restricts student creation.');
      }
      throw Exception('Scan failed: $e');
    }
  }

  // Reset system (admin only)
  Future<void> resetSystem() async {
    try {
      final success = await _supabase.resetSystem();
      if (!success) {
        throw Exception('Reset failed');
      }
      await fetchAllData();
    } catch (e) {
      debugPrint('Reset error: $e');
      throw Exception('Reset failed: $e');
    }
  }

  // Update library capacity (admin only)
  Future<void> updateCapacity(int totalSeats) async {
    try {
      final success = await _supabase.updateCapacity(totalSeats);
      if (!success) {
        throw Exception('Update failed');
      }
      await fetchLibraryStatus();
      await fetchSeatMap();
    } catch (e) {
      debugPrint('Update capacity error: $e');
      throw Exception('Update failed: $e');
    }
  }

  // Auto-refresh
  void startAutoRefresh({String? studentId}) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 10), // Refresh every 10 seconds
      (_) => fetchAllData(studentId: studentId),
    );
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  // Refresh all data (alias for UI)
  Future<void> refreshData({String? studentId}) async {
    await fetchAllData(studentId: studentId);
  }

  // ============ ADMIN OPERATIONS ============

  /// Add a new student (admin only)
  Future<Student?> addStudent(String studentId, {String? name}) async {
    try {
      final student = await _supabase.addStudent(studentId, name: name);
      if (student != null) {
        await fetchAllData();
      }
      return student;
    } catch (e) {
      debugPrint('Add student error: $e');
      return null;
    }
  }

  /// Get all students (admin management)
  Future<List<Student>> getAllStudents() async {
    try {
      return await _supabase.getAllStudents();
    } catch (e) {
      debugPrint('Get all students error: $e');
      return [];
    }
  }

  /// Delete a student (admin only)
  Future<bool> deleteStudent(String studentId) async {
    try {
      // Optimistically remove from local state for instant UI sync
      _studentsInside.removeWhere((s) => s.id == studentId);
      _syncLibraryStatus();
      debugPrint(
          '[LibraryProvider] deleteStudent -> removed $studentId locally, count: ${_studentsInside.length}');
      notifyListeners();

      final success = await _supabase.deleteStudent(studentId);
      if (success) {
        await fetchAllData();
      }
      return success;
    } catch (e) {
      debugPrint('Delete student error: $e');
      return false;
    }
  }

  /// Force exit a student (admin only)
  Future<bool> forceExitStudent(String studentId,
      {String studentName = 'Unknown'}) async {
    try {
      // Optimistically remove from local state for instant UI sync
      _studentsInside.removeWhere((s) => s.id == studentId);
      _syncLibraryStatus();
      debugPrint(
          '[LibraryProvider] forceExitStudent -> removed $studentId locally, count: ${_studentsInside.length}');
      notifyListeners();

      final supabase = Supabase.instance.client;

      final student = await _supabase.getStudent(studentId);
      final currentScanCount = student?.scanCount ?? 0;

      await supabase.from('students').update({
        'current_status': 'OUTSIDE',
        'scan_count': currentScanCount + 1,
      }).eq('id', studentId);

      await supabase.from('scan_logs').insert({
        'student_id': studentId,
        'scan_type': 'EXIT',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final configResponse =
          await supabase.from('library_config').select().limit(1).maybeSingle();
      if (configResponse != null) {
        int occupiedSeats = configResponse['occupied_seats'] ?? 0;
        occupiedSeats = (occupiedSeats - 1).clamp(0, 9999);
        await supabase.from('library_config').update({
          'occupied_seats': occupiedSeats,
          'last_updated': DateTime.now().toIso8601String(),
        }).eq('id', configResponse['id']);
      }

      await fetchAllData();

      return true;
    } catch (e) {
      debugPrint('Force exit error: $e');
      return false;
    }
  }

  /// Update student name
  Future<bool> updateStudentName(String studentId, String newName) async {
    try {
      final success = await _supabase.updateStudentName(studentId, newName);
      if (success) {
        await fetchAllData();
      }
      return success;
    } catch (e) {
      debugPrint('Update student name error: $e');
      return false;
    }
  }

  /// Clear all data (admin only - use with caution!)
  Future<bool> clearAllData() async {
    try {
      final success = await _supabase.clearAllData();
      if (success) {
        await fetchAllData();
      }
      return success;
    } catch (e) {
      debugPrint('Clear all data error: $e');
      return false;
    }
  }

  /// Update library settings
  Future<bool> updateLibrarySettings(
      {int? totalSeats, int? occupiedSeats}) async {
    try {
      final success = await _supabase.updateLibrarySettings(
        totalSeats: totalSeats,
        occupiedSeats: occupiedSeats,
      );
      if (success) {
        await fetchLibraryStatus();
        await fetchSeatMap();
      }
      return success;
    } catch (e) {
      debugPrint('Update settings error: $e');
      rethrow;
    }
  }

  /// Fetch seat map
  Future<void> fetchSeatMap() async {
    try {
      final seatMap = await _supabase.getSeatMap();
      _seatMap = seatMap;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch seat map error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    // Clean up subscriptions
    if (_statusChannel != null) {
      _supabase.unsubscribe(_statusChannel!);
    }
    if (_logsChannel != null) {
      _supabase.unsubscribe(_logsChannel!);
    }
    super.dispose();
  }
}
