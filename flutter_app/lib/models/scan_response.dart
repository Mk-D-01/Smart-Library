import 'student.dart';
import 'library_status.dart';

class ScanResponse {
  final bool success;
  final String action;
  final Student student;
  final LibraryStatus libraryStatus;
  final String? error;

  ScanResponse({
    required this.success,
    required this.action,
    required this.student,
    required this.libraryStatus,
    this.error,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      success: json['success'] ?? false,
      action: json['action'] ?? '',
      student: Student.fromJson(json['student'] ?? {}),
      libraryStatus: LibraryStatus.fromJson(json['libraryStatus'] ?? {}),
      error: json['error'],
    );
  }

  bool get isEntry => action == 'ENTRY';
}
