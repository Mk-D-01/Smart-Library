class ScanLog {
  final int? id;
  final String studentId;
  final String scanType;
  final DateTime timestamp;

  ScanLog({
    this.id,
    required this.studentId,
    required this.scanType,
    required this.timestamp,
  });

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id'],
      studentId: json['student_id'],
      scanType: json['scan_type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  bool get isEntry => scanType == 'ENTRY';
  
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
  
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
