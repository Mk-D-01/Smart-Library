import 'seat.dart';

class SeatMap {
  final List<List<Seat>> seats;
  final int totalSeats;
  final int occupiedSeats;
  final int availableSeats;
  final int occupancyRate;
  final int rows;
  final int cols;
  final DateTime lastUpdated;

  SeatMap({
    required this.seats,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.occupancyRate,
    required this.rows,
    required this.cols,
    required this.lastUpdated,
  });

  factory SeatMap.fromJson(Map<String, dynamic> json) {
    final List<dynamic> seatsJson = json['seats'] ?? [];
    final List<List<Seat>> seats = seatsJson.map((row) {
      return (row as List<dynamic>).map((seat) => Seat.fromJson(seat)).toList();
    }).toList();

    return SeatMap(
      seats: seats,
      totalSeats: json['totalSeats'] ?? 0,
      occupiedSeats: json['occupiedSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      occupancyRate: json['occupancyRate'] ?? 0,
      rows: json['rows'] ?? 0,
      cols: json['cols'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }
}
