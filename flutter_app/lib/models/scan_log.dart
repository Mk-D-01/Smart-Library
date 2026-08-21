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
    // Handle timestamp that could be String or DateTime
    DateTime parsedTimestamp;
    final timestampValue = json['timestamp'];
    if (timestampValue is DateTime) {
      parsedTimestamp = timestampValue.toLocal();
    } else if (timestampValue is String) {
      parsedTimestamp = DateTime.tryParse(timestampValue)?.toLocal() ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }
    
    return ScanLog(
      id: json['id'],
      studentId: json['student_id'] ?? '',
      scanType: json['scan_type'] ?? 'UNKNOWN',
      timestamp: parsedTimestamp,
    );
  }

  bool get isEntry => scanType == 'ENTRY';
  
  String get formattedTime {
    final localTime = timestamp.toLocal();
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }
  
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
