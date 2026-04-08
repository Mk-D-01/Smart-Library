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

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'] ?? 'Student ${json['id']}',
      currentStatus: json['current_status'] ?? 'OUTSIDE',
      scanCount: json['scan_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  bool get isInside => currentStatus == 'INSIDE';
}
