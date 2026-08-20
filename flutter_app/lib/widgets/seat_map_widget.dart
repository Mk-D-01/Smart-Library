import 'package:flutter/material.dart';
import '../models/seat_map.dart';
import '../models/seat.dart';
import '../config/theme_config.dart';

class SeatMapWidget extends StatelessWidget {
  final SeatMap seatMap;
  final Function(Seat)? onSeatTap;

  const SeatMapWidget({
    super.key,
    required this.seatMap,
    this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legend
        _buildLegend(),
        const SizedBox(height: 16),
        // Stats
        _buildStats(),
        const SizedBox(height: 16),
        // Seat Grid
        Expanded(
          child: _buildSeatGrid(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final isDark = AppTheme.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green.shade400, 'Available'),
          const SizedBox(width: 20),
          _legendItem(Colors.red.shade400, 'Occupied'),
          const SizedBox(width: 20),
          _legendItem(Colors.grey.shade300, 'Empty'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total',
            seatMap.totalSeats.toString(),
            Colors.blue.shade100,
            Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Occupied',
            seatMap.occupiedSeats.toString(),
            Colors.red.shade100,
            Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Available',
            seatMap.availableSeats.toString(),
            Colors.green.shade100,
            Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Rate',
            '${seatMap.occupancyRate}%',
            Colors.orange.shade100,
            Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    final isDark = AppTheme.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Column headers (A, B, C...)
          _buildColumnHeaders(),
          const SizedBox(height: 8),
          // Seat rows
          Expanded(
            child: ListView.builder(
              itemCount: seatMap.seats.length,
              itemBuilder: (context, rowIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildSeatRow(seatMap.seats[rowIndex], rowIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    final isDark = AppTheme.isDarkMode;
    final headers = List.generate(seatMap.cols, (i) {
      return String.fromCharCode(65 + i); // A, B, C...
    });

    return Row(
      children: [
        // Row number spacer
        const SizedBox(width: 40),
        // Column letters
        for (final header in headers)
          Expanded(
            child: Center(
              child: Text(
                header,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade400 : AppTheme.textTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSeatRow(List<Seat> row, int rowIndex) {
    final isDark = AppTheme.isDarkMode;
    return Row(
      children: [
        // Row number
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '${rowIndex + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : AppTheme.textTertiary,
              ),
            ),
          ),
        ),
        // Seat cells
        for (final seat in row)
          Expanded(
            child: _buildSeatCell(seat),
          ),
      ],
    );
  }

  Widget _buildSeatCell(Seat seat) {
    final isOccupied = seat.isOccupied;
    final color = isOccupied ? Colors.red.shade400 : Colors.green.shade400;
    final shadowColor =
        isOccupied ? Colors.red.shade200 : Colors.green.shade200;

    return GestureDetector(
      onTap: onSeatTap != null ? () => onSeatTap!(seat) : null,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Tooltip(
          message: isOccupied
              ? 'Seat ${seat.id}: ${seat.student?.name ?? 'Occupied'}'
              : 'Seat ${seat.id}: Available',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isOccupied
                  ? const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${seat.id}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
