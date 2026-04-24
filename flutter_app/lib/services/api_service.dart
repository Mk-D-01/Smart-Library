import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/library_status.dart';
import '../models/student.dart';
import '../models/scan_response.dart';
import '../models/scan_log.dart';
import '../models/seat_map.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // GET Library Status
  Future<LibraryStatus> getLibraryStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConfig.status}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final data = body['data'] ?? body;
        return LibraryStatus.fromJson(data);
      } else {
        throw Exception('Failed to load library status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Process Scan
  Future<ScanResponse> processScan(String studentId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConfig.scan}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'studentId': studentId}),
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ScanResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Scan failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET Students Inside
  Future<List<Student>> getStudentsInside() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConfig.studentsInside}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET Scan Logs
  Future<List<ScanLog>> getScanLogs({int limit = 20, String? studentId}) async {
    try {
      var url = '$baseUrl${ApiConfig.scanLogs}?limit=$limit';
      if (studentId != null) {
        url += '&studentId=$studentId';
      }
      
      final response = await http
          .get(Uri.parse(url))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((json) => ScanLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scan logs');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Reset System (Admin only)
  Future<void> resetSystem() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl${ApiConfig.reset}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Reset failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConfig.health}'))
          .timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // GET Student Info (for login - optional, can validate client-side)
  Future<Student?> getStudentInfo(String studentId) async {
    try {
      // This endpoint might not exist yet - implement if needed
      final response = await http
          .get(Uri.parse('$baseUrl/student/$studentId'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return Student.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // GET Seat Map
  Future<SeatMap> getSeatMap() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConfig.seats}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final data = body['data'] ?? body;
        return SeatMap.fromJson(data);
      } else {
        throw Exception('Failed to load seat map');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
