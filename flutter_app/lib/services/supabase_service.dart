import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/library_status.dart';
import '../models/student.dart';
import '../models/scan_log.dart';
import '../models/seat_map.dart';

/// Service for direct Supabase database operations
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ============ LIBRARY STATUS ============

  /// Get current library status (occupied seats, total capacity)
  Future<LibraryStatus> getLibraryStatus() async {
    try {
      final response = await _client
          .from(SupabaseConfig.libraryConfigTable)
          .select()
          .limit(1)
          .single();

      final totalSeats = response['total_seats'] ?? 100;
      final occupiedSeats = response['occupied_seats'] ?? 0;
      final availableSeats = totalSeats - occupiedSeats;
      final occupancyPercentage =
          totalSeats > 0 ? (occupiedSeats / totalSeats) * 100 : 0.0;

      return LibraryStatus(
        totalSeats: totalSeats,
        occupiedSeats: occupiedSeats,
        availableSeats: availableSeats,
        occupancyPercentage: occupancyPercentage,
      );
    } catch (e) {
      debugPrint('Error getting library status: $e');
      // Return default status if config doesn't exist
      return LibraryStatus(
        totalSeats: 100,
        occupiedSeats: 0,
        availableSeats: 100,
        occupancyPercentage: 0,
      );
    }
  }

  // ============ STUDENTS ============

  /// Get list of students currently inside the library
  Future<List<Student>> getStudentsInside() async {
    try {
      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .select()
          .eq('current_status', 'INSIDE')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting students inside: $e');
      return [];
    }
  }

  /// Get student by ID
  Future<Student?> getStudent(String studentId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .select()
          .eq('id', studentId)
          .maybeSingle();

      if (response != null) {
        return Student.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting student: $e');
      return null;
    }
  }

  /// Check if student exists in database
  Future<bool> studentExists(String studentId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .select('id')
          .eq('id', studentId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking student: $e');
      return false;
    }
  }

  /// Create or update student (upsert)
  Future<Student?> upsertStudent(String studentId, {String? name}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .upsert({
            'id': studentId,
            'name': name ?? 'Student $studentId',
            'current_status': 'OUTSIDE',
            'scan_count': 0,
          }, onConflict: 'id')
          .select()
          .single();

      return Student.fromJson(response);
    } catch (e) {
      debugPrint('Error upserting student: $e');
      return null;
    }
  }

  // ============ SCAN OPERATIONS ============

  /// Process a scan (entry/exit)
  Future<Map<String, dynamic>> processScan(String studentId) async {
    try {
      // Get or create student
      var studentResponse = await _client
          .from(SupabaseConfig.studentsTable)
          .select()
          .eq('id', studentId)
          .maybeSingle();

      int currentScanCount = 0;

      if (studentResponse == null) {
        // Create new student with default email
        await _client.from(SupabaseConfig.studentsTable).insert({
          'id': studentId,
          'name': 'Student $studentId',
          'email': '$studentId@student.edu',
          'current_status': 'OUTSIDE',
          'scan_count': 0,
        });
      } else {
        currentScanCount = studentResponse['scan_count'] ?? 0;
      }

      // Determine action based on scan count (odd/even logic)
      final bool isEntry = currentScanCount % 2 == 0;
      final String action = isEntry ? 'ENTRY' : 'EXIT';
      final String newStatus = isEntry ? 'INSIDE' : 'OUTSIDE';

      // Update student
      await _client.from(SupabaseConfig.studentsTable).update({
        'current_status': newStatus,
        'scan_count': currentScanCount + 1,
      }).eq('id', studentId);

      // Log the scan
      await _client.from(SupabaseConfig.scanLogsTable).insert({
        'student_id': studentId,
        'scan_type': action,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update library config
      final configResponse = await _client
          .from(SupabaseConfig.libraryConfigTable)
          .select()
          .limit(1)
          .maybeSingle();

      if (configResponse != null) {
        int occupiedSeats = configResponse['occupied_seats'] ?? 0;
        if (isEntry) {
          occupiedSeats += 1;
        } else {
          occupiedSeats = (occupiedSeats - 1).clamp(0, 9999);
        }

        await _client.from(SupabaseConfig.libraryConfigTable).update({
          'occupied_seats': occupiedSeats,
          'last_updated': DateTime.now().toIso8601String(),
        }).eq('id', configResponse['id']);
      }

      return {
        'success': true,
        'action': action,
        'studentId': studentId,
        'newStatus': newStatus,
      };
    } catch (e) {
      debugPrint('Error processing scan: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ SCAN LOGS ============

  /// Get scan logs with optional filters
  Future<List<ScanLog>> getScanLogs({
    int limit = 20,
    String? studentId,
  }) async {
    try {
      var query = _client.from(SupabaseConfig.scanLogsTable).select();

      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }

      final response =
          await query.order('timestamp', ascending: false).limit(limit);

      return (response as List).map((json) => ScanLog.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting scan logs: $e');
      return [];
    }
  }

  /// Get scan logs for a specific student
  Future<List<ScanLog>> getStudentScanLogs(String studentId,
      {int limit = 50}) async {
    return getScanLogs(studentId: studentId, limit: limit);
  }

  // ============ ADMIN OPERATIONS ============

  /// Reset system - mark all students as OUTSIDE, reset occupied seats
  Future<bool> resetSystem() async {
    try {
      // Mark all students as OUTSIDE
      await _client.from(SupabaseConfig.studentsTable).update({
        'current_status': 'OUTSIDE',
        'scan_count': 0,
      }).neq('id', '');

      // Reset occupied seats
      await _client.from(SupabaseConfig.libraryConfigTable).update({
        'occupied_seats': 0,
        'last_updated': DateTime.now().toIso8601String(),
      }).neq('id', 0);

      return true;
    } catch (e) {
      debugPrint('Error resetting system: $e');
      return false;
    }
  }

  /// Update library capacity
  Future<bool> updateCapacity(int totalSeats) async {
    try {
      await _client.from(SupabaseConfig.libraryConfigTable).update({
        'total_seats': totalSeats,
        'last_updated': DateTime.now().toIso8601String(),
      }).neq('id', 0);

      return true;
    } catch (e) {
      debugPrint('Error updating capacity: $e');
      return false;
    }
  }

  // ============ REAL-TIME SUBSCRIPTIONS ============

  /// Subscribe to library status changes
  RealtimeChannel subscribeToLibraryStatus(void Function(dynamic) callback) {
    return _client
        .channel('library_status')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConfig.libraryConfigTable,
          callback: (payload) => callback(payload),
        )
        .subscribe();
  }

  /// Subscribe to scan logs (for real-time activity feed)
  RealtimeChannel subscribeToScanLogs(void Function(dynamic) callback) {
    return _client
        .channel('scan_logs')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.scanLogsTable,
          callback: (payload) => callback(payload),
        )
        .subscribe();
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  // ============ VALIDATION ============

  /// Validate 11-digit student ID format
  static bool isValidStudentId(String id) {
    if (id.length != 11) return false;
    if (!RegExp(r'^\d{11}$').hasMatch(id)) return false;
    return true;
  }

  /// Validate admin credentials
  static bool isValidAdminId(String id) {
    return id.toUpperCase() == 'ADMIN' ||
        id.toUpperCase() == 'LIBRARIAN' ||
        id.startsWith('ADM');
  }

  // ============ ADMIN OPERATIONS ============

  /// Add a new student to the database (Admin only)
  Future<Student?> addStudent(String studentId,
      {String? name, String? email}) async {
    try {
      final existing = await getStudent(studentId);
      if (existing != null) {
        debugPrint('Student $studentId already exists');
        return existing;
      }

      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .insert({
            'id': studentId,
            'name': name ?? 'Student $studentId',
            'email': email ?? '$studentId@student.edu',
            'current_status': 'OUTSIDE',
            'scan_count': 0,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Student.fromJson(response);
    } catch (e) {
      debugPrint('Error adding student: $e');
      return null;
    }
  }

  /// Get all students (for admin management)
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await _client
          .from(SupabaseConfig.studentsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting all students: $e');
      return [];
    }
  }

  /// Delete a student (Admin only)
  Future<bool> deleteStudent(String studentId) async {
    try {
      // Check if student was inside before deleting
      final student = await getStudent(studentId);
      if (student != null && student.currentStatus == 'INSIDE') {
        // Decrement occupied seats
        final configResponse = await _client
            .from(SupabaseConfig.libraryConfigTable)
            .select()
            .limit(1)
            .maybeSingle();

        if (configResponse != null) {
          int occupiedSeats = configResponse['occupied_seats'] ?? 0;
          occupiedSeats = (occupiedSeats - 1).clamp(0, 9999);

          await _client.from(SupabaseConfig.libraryConfigTable).update({
            'occupied_seats': occupiedSeats,
            'last_updated': DateTime.now().toIso8601String(),
          }).eq('id', configResponse['id']);
        }
      }

      // Delete scan logs
      await _client
          .from(SupabaseConfig.scanLogsTable)
          .delete()
          .eq('student_id', studentId);

      // Delete student
      await _client
          .from(SupabaseConfig.studentsTable)
          .delete()
          .eq('id', studentId);

      return true;
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
    }
  }

  /// Update student name
  Future<bool> updateStudentName(String studentId, String newName) async {
    try {
      await _client.from(SupabaseConfig.studentsTable).update({
        'name': newName,
      }).eq('id', studentId);

      return true;
    } catch (e) {
      debugPrint('Error updating student name: $e');
      return false;
    }
  }

  /// Clear all data (Admin only - use with caution!)
  Future<bool> clearAllData() async {
    try {
      await _client.from(SupabaseConfig.scanLogsTable).delete().neq('id', 0);

      await _client.from(SupabaseConfig.studentsTable).delete().neq('id', '');

      await _client.from(SupabaseConfig.libraryConfigTable).update({
        'occupied_seats': 0,
        'last_updated': DateTime.now().toIso8601String(),
      }).neq('id', 0);

      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  /// Update library settings (total seats, etc.)
  Future<bool> updateLibrarySettings({
    int? totalSeats,
    int? occupiedSeats,
  }) async {
    try {
      final updates = <String, dynamic>{
        'last_updated': DateTime.now().toIso8601String(),
      };

      if (totalSeats != null) updates['total_seats'] = totalSeats;
      if (occupiedSeats != null) updates['occupied_seats'] = occupiedSeats;

      await _client
          .from(SupabaseConfig.libraryConfigTable)
          .update(updates)
          .neq('id', 0);

      return true;
    } catch (e) {
      debugPrint('Error updating library settings: $e');
      return false;
    }
  }

  /// Get seat map pictograph data
  Future<SeatMap> getSeatMap() async {
    try {
      // Get library config for total seats
      final config = await _client
          .from(SupabaseConfig.libraryConfigTable)
          .select()
          .limit(1)
          .single();

      final totalSeats = config['total_seats'] ?? 100;

      // Get students currently inside
      final students = await getStudentsInside();

      // Generate seat grid
      const cols = 10;
      final rows = (totalSeats / cols).ceil();

      final List<List<Map<String, dynamic>>> seats = [];
      int seatNumber = 1;

      for (int row = 0; row < rows; row++) {
        final List<Map<String, dynamic>> rowSeats = [];
        for (int col = 0; col < cols; col++) {
          if (seatNumber <= totalSeats) {
            final studentIndex = seatNumber - 1;
            final student =
                studentIndex < students.length ? students[studentIndex] : null;

            rowSeats.add({
              'id': seatNumber,
              'row': row + 1,
              'col': col + 1,
              'status': student != null ? 'OCCUPIED' : 'AVAILABLE',
              'student': student != null
                  ? {
                      'id': student.id,
                      'name': student.name,
                    }
                  : null,
            });
            seatNumber++;
          }
        }
        seats.add(rowSeats);
      }

      return SeatMap.fromJson({
        'seats': seats,
        'totalSeats': totalSeats,
        'occupiedSeats': students.length,
        'availableSeats': totalSeats - students.length,
        'occupancyRate':
            totalSeats > 0 ? ((students.length / totalSeats) * 100).round() : 0,
        'rows': rows,
        'cols': cols,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error getting seat map: $e');
      // Return default empty seat map
      return SeatMap.fromJson({
        'seats': [],
        'totalSeats': 100,
        'occupiedSeats': 0,
        'availableSeats': 100,
        'occupancyRate': 0,
        'rows': 10,
        'cols': 10,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    }
  }
}
