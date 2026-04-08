class Student {
  final String id;
  final String name;
  final String currentStatus;
  final int scanCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.currentStatus,
    required this.scanCount,
    this.createdAt,
    this.updatedAt,
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
    );
  }

  bool get isInside => currentStatus == 'INSIDE';
}
