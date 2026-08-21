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

  /// Robust timestamp parser for Student fields (createdAt, updatedAt, entryTime).
  /// Compares with device now and corrects for any UTC/local database offset double-addition.
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    DateTime dt;
    if (value is DateTime) {
      dt = value.toLocal();
    } else if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      dt = parsed.toLocal();
    } else {
      return null;
    }

    final now = DateTime.now();
    // If the timestamp is in the future by > 1 minute, compensate for local clock stored in UTC column
    if (dt.isAfter(now.add(const Duration(minutes: 1)))) {
      dt = dt.subtract(now.timeZoneOffset);
    }
    return dt;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Student ${json['id']}',
      currentStatus: json['current_status'] ?? 'OUTSIDE',
      scanCount: json['scan_count'] ?? 0,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      entryTime: parseDateTime(json['entryTime'] ?? json['entry_time']),
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
