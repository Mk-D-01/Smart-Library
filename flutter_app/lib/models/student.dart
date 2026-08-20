class Student {
  final String id;
  final String name;
  final String currentStatus;
  final int scanCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? entryTime;
  final String? course;
  final String? degree;
  final String? phone;
  final int? semester;

  Student({
    required this.id,
    required this.name,
    required this.currentStatus,
    required this.scanCount,
    this.createdAt,
    this.updatedAt,
    this.entryTime,
    this.course,
    this.degree,
    this.phone,
    this.semester,
  });

  // Helper to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Student ${json['id']}',
      currentStatus: json['current_status'] ?? 'OUTSIDE',
      scanCount: json['scan_count'] ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      entryTime: _parseDateTime(json['entryTime'] ?? json['entry_time']),
      course: json['course']?.toString(),
      degree: json['degree']?.toString(),
      phone: json['phone']?.toString(),
      semester: json['semester'] != null ? int.tryParse(json['semester'].toString()) : null,
    );
  }

  bool get isInside => currentStatus == 'INSIDE';

  /// Get the display course/program name
  String? get displayCourse => course ?? degree;

  /// Get the actual library entry time (from scan_logs), falling back to createdAt
  DateTime? get libraryEntryTime => entryTime ?? createdAt;
}
