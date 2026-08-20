import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/seat_map.dart';
import '../models/seat.dart';
import '../config/theme_config.dart';

class SeatMapWidget extends StatefulWidget {
  final SeatMap seatMap;
  final Function(Seat)? onSeatTap;

  const SeatMapWidget({
    super.key,
    required this.seatMap,
    this.onSeatTap,
  });

  @override
  State<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> {
  int _selectedZone = 1;

  final List<Map<String, dynamic>> _zones = [
    {'zone': 1, 'label': 'Zone 1', 'range': '1–100', 'desc': 'Ground Floor • North'},
    {'zone': 2, 'label': 'Zone 2', 'range': '101–200', 'desc': 'Floor 1 • East Wing'},
    {'zone': 3, 'label': 'Zone 3', 'range': '201–300', 'desc': 'Floor 2 • West Wing'},
    {'zone': 4, 'label': 'Zone 4', 'range': '301–350', 'desc': 'Floor 3 • Silent Study'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Multi-Zone Selector Bar
        _buildZoneSelector(isDark),
        const SizedBox(height: 12),
        // Legend
        _buildLegend(isDark),
        const SizedBox(height: 12),
        // Stats
        _buildStats(isDark),
        const SizedBox(height: 12),
        // Seat Grid
        Expanded(
          child: _buildSeatGrid(isDark),
        ),
      ],
    );
  }

  Widget _buildZoneSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.layers_rounded,
                  color: isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Library Zones (350 Seats)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Zone $_selectedZone',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _zones.map((zoneData) {
              final zone = zoneData['zone'] as int;
              final isSelected = _selectedZone == zone;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedZone = zone;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          zoneData['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppTheme.textPrimary),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          zoneData['range'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : (isDark ? Colors.grey.shade400 : AppTheme.textSecondary),
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(const Color(0xFF10B981), 'Available', isDark),
          const SizedBox(width: 20),
          _legendItem(const Color(0xFFEF4444), 'Occupied', isDark),
          const SizedBox(width: 20),
          _legendItem(isDark ? const Color(0xFF334155) : Colors.grey.shade300, 'Buffer', isDark),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade300 : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total',
            '350',
            isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : Colors.blue.shade50,
            isDark ? const Color(0xFF93C5FD) : Colors.blue.shade700,
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Occupied',
            widget.seatMap.occupiedSeats.toString(),
            isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : Colors.red.shade50,
            isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700,
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Available',
            widget.seatMap.availableSeats.toString(),
            isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : Colors.green.shade50,
            isDark ? const Color(0xFF6EE7B7) : Colors.green.shade700,
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Rate',
            '${widget.seatMap.occupancyRate}%',
            isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : Colors.orange.shade50,
            isDark ? const Color(0xFFFCD34D) : Colors.orange.shade700,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color bgColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid(bool isDark) {
    final zoneOffset = (_selectedZone - 1) * 100;
    const totalCapacity = 350;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildColumnHeaders(isDark),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 10, // 10 rows per zone
              itemBuilder: (context, rowIndex) {
                final rowLetter = String.fromCharCode(65 + rowIndex); // A-J
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      // Row Letter
                      SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            rowLetter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade400 : AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      // 10 Seat Cells
                      ...List.generate(10, (colIndex) {
                        final deskNumber = zoneOffset + (rowIndex * 10) + colIndex + 1;
                        if (deskNumber > totalCapacity) {
                          // Buffer
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                                  ),
                                ),
                                child: const Center(
                                  child: Text('--', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ),
                              ),
                            ),
                          );
                        }

                        final isOccupied = deskNumber <= widget.seatMap.occupiedSeats;
                        final seat = Seat(
                          id: deskNumber,
                          row: rowIndex + 1,
                          col: colIndex + 1,
                          status: isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                        );

                        return Expanded(
                          child: _buildSeatCell(seat, deskNumber, isDark),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(bool isDark) {
    return Row(
      children: [
        const SizedBox(width: 28),
        ...List.generate(10, (i) {
          return Expanded(
            child: Center(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade400 : AppTheme.textTertiary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeatCell(Seat seat, int deskNumber, bool isDark) {
    final isOccupied = seat.isOccupied;
    final color = isOccupied ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onSeatTap != null) {
          widget.onSeatTap!(seat);
        } else {
          _showSeatDetailsModal(seat, deskNumber, isDark);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Tooltip(
          message: isOccupied
              ? 'Desk #$deskNumber (Zone $_selectedZone): Occupied'
              : 'Desk #$deskNumber (Zone $_selectedZone): Available',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Center(
              child: isOccupied
                  ? const Icon(
                      Icons.person,
                      size: 13,
                      color: Colors.white,
                    )
                  : Text(
                      '$deskNumber',
                      style: const TextStyle(
                        fontSize: 8,
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

  void _showSeatDetailsModal(Seat seat, int deskNumber, bool isDark) {
    final isOccupied = seat.isOccupied;
    final rowLetter = String.fromCharCode(64 + seat.row);
    final demoStudentName = 'Student $deskNumber';
    final demoStudentId = 'STU${deskNumber.toString().padLeft(3, '0')}';
    final studentName = seat.student?.name ?? (isOccupied ? demoStudentName : null);
    final studentId = seat.student?.id ?? (isOccupied ? demoStudentId : null);
    final studentCourse = seat.student?.course;
    
    // Parse real entry time from backend, or compute a fallback
    final rawEntryTime = seat.student?.entryTime;
    final entryDateTime = rawEntryTime != null ? DateTime.tryParse(rawEntryTime) : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOccupied
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isOccupied ? Icons.person_rounded : Icons.chair_rounded,
                        color: isOccupied ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Desk #$deskNumber ($rowLetter${seat.col})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Zone $_selectedZone • Row $rowLetter • Col ${seat.col}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOccupied ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Student Profile Card if Occupied
                if (isOccupied) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                                studentName != null && studentName.isNotEmpty
                                    ? studentName[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName ?? 'Active Student',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'ID: $studentId${studentCourse != null ? ' • $studentCourse' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade400 : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time in Library',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              () {
                                if (entryDateTime != null) {
                                  final diff = DateTime.now().difference(entryDateTime);
                                  final hours = diff.inHours;
                                  final mins = diff.inMinutes % 60;
                                  if (hours > 0) return '${hours}h ${mins}m';
                                  if (mins > 0) return '${mins}m';
                                  return '${diff.inSeconds}s';
                                }
                                // Fallback for demo
                                final elapsedMins = ((deskNumber * 13 + 7) % 160 + 2);
                                final hours = elapsedMins ~/ 60;
                                final mins = elapsedMins % 60;
                                return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
                              }(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.2) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This desk is vacant and ready for check-in.',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
