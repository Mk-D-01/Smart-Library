import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class LibraryStatus {
  final int totalSeats;
  final int occupiedSeats;
  final int availableSeats;
  final double occupancyPercentage;

  LibraryStatus({
    required this.totalSeats,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.occupancyPercentage,
  });

  factory LibraryStatus.fromJson(Map<String, dynamic> json) {
    return LibraryStatus(
      totalSeats: json['totalSeats'] ?? 100,
      occupiedSeats: json['occupiedSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 100,
      occupancyPercentage: (json['occupancyPercentage'] ?? json['occupancyRate'] ?? 0).toDouble(),
    );
  }

  String get statusText {
    if (occupancyPercentage >= 90) return 'Full';
    if (occupancyPercentage >= 70) return 'Crowded';
    if (occupancyPercentage >= 40) return 'Moderate';
    return 'Available';
  }

  Color get statusColor {
    if (occupancyPercentage >= 80) return AppTheme.accentRed;
    if (occupancyPercentage >= 50) return AppTheme.accentAmber;
    return AppTheme.accentGreen;
  }
}
