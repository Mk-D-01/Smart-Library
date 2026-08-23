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

  /// Robust parser for timestamps from Supabase.
  /// Handles both standard UTC ISO strings and timestamps that were saved with local clock.
  static DateTime parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    DateTime dt;
    if (value is DateTime) {
      dt = value.toLocal();
    } else if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return DateTime.now();
      dt = parsed.toLocal();
    } else {
      return DateTime.now();
    }

    final now = DateTime.now();
    // If the parsed timestamp is in the future by more than 1 minute,
    // it was saved as a local time string into a UTC column (offset added twice).
    // Compensate by subtracting the timestamp's timezone offset (DST-safe).
    if (dt.isAfter(now.add(const Duration(minutes: 1)))) {
      dt = dt.subtract(dt.timeZoneOffset);
    }
    return dt;
  }

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id'],
      studentId: json['student_id']?.toString() ?? '',
      scanType: json['scan_type']?.toString() ?? 'UNKNOWN',
      timestamp: parseTimestamp(json['timestamp']),
    );
  }

  bool get isEntry => scanType == 'ENTRY';

  /// Formatted 12-hour local time: e.g. "11:29 PM"
  String get formattedTime {
    final localTime = timestamp.toLocal();
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// Relative elapsed time: e.g. "Just now", "25s ago", "2m ago", "1h ago"
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toLocal());

    if (difference.isNegative || difference.inSeconds < 10) return 'Just now';
    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
