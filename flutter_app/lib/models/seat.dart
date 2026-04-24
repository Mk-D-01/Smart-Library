class SeatStudent {
  final String id;
  final String name;

  SeatStudent({
    required this.id,
    required this.name,
  });

  factory SeatStudent.fromJson(Map<String, dynamic> json) {
    return SeatStudent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
    );
  }
}

class Seat {
  final int id;
  final int row;
  final int col;
  final String status; // 'AVAILABLE', 'OCCUPIED', 'RESERVED'
  final SeatStudent? student;

  Seat({
    required this.id,
    required this.row,
    required this.col,
    required this.status,
    this.student,
  });

  bool get isOccupied => status == 'OCCUPIED';
  bool get isAvailable => status == 'AVAILABLE';

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] ?? 0,
      row: json['row'] ?? 0,
      col: json['col'] ?? 0,
      status: json['status'] ?? 'AVAILABLE',
      student: json['student'] != null ? SeatStudent.fromJson(json['student']) : null,
    );
  }
}
