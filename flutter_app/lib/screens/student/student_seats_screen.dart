import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/seat_map_widget.dart';

/// Student Seats Screen - Interactive Multi-Zone Seat Map for students
class StudentSeatsScreen extends StatefulWidget {
  const StudentSeatsScreen({super.key});

  @override
  State<StudentSeatsScreen> createState() => _StudentSeatsScreenState();
}

class _StudentSeatsScreenState extends State<StudentSeatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSeatMap();
    });
  }

  Future<void> _refreshSeatMap() async {
    await Provider.of<LibraryProvider>(context, listen: false).fetchSeatMap();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Library Seats'),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () => themeProvider.toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Seats',
                onPressed: _refreshSeatMap,
              ),
            ],
          ),
          body: Consumer<LibraryProvider>(
            builder: (context, libraryProvider, child) {
              if (libraryProvider.isLoading && libraryProvider.seatMap == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                );
              }

              if (libraryProvider.error != null && libraryProvider.seatMap == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.accentRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load seat map',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        libraryProvider.error!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshSeatMap,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final seatMap = libraryProvider.seatMap;
              if (seatMap == null) {
                return const Center(
                  child: Text('No seat map data available'),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshSeatMap,
                color: AppTheme.primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SeatMapWidget(
                    seatMap: seatMap,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
