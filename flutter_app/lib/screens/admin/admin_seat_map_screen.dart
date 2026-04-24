import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/seat_map_widget.dart';
import '../../config/theme_config.dart';

class AdminSeatMapScreen extends StatefulWidget {
  const AdminSeatMapScreen({super.key});

  @override
  State<AdminSeatMapScreen> createState() => _AdminSeatMapScreenState();
}

class _AdminSeatMapScreenState extends State<AdminSeatMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).fetchSeatMap();
    });
  }

  Future<void> _refreshSeatMap() async {
    await Provider.of<LibraryProvider>(context, listen: false).fetchSeatMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.chair,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Seat Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshSeatMap,
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading && libraryProvider.seatMap == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            );
          }

          if (libraryProvider.error != null && libraryProvider.seatMap == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading seat map',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    libraryProvider.error!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
                onSeatTap: (seat) {
                  if (seat.isOccupied && seat.student != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Seat Information'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seat #${seat.id}'),
                            const SizedBox(height: 8),
                            Text('Student: ${seat.student!.name}'),
                            Text('ID: ${seat.student!.id}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
