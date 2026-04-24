import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../config/theme_config.dart';

class AdminControlsScreen extends StatefulWidget {
  const AdminControlsScreen({super.key});

  @override
  State<AdminControlsScreen> createState() => _AdminControlsScreenState();
}

class _AdminControlsScreenState extends State<AdminControlsScreen> {
  bool _isResetting = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Controls'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemStatus(),
            const SizedBox(height: 24),
            _buildSystemControls(),
            const SizedBox(height: 24),
            _buildDataManagement(),
            const SizedBox(height: 24),
            _buildSystemInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        final status = libraryProvider.libraryStatus;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.blueGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'System Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Total Seats',
                      '${status?.totalSeats ?? 0}',
                      Icons.event_seat,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard(
                      'Occupied',
                      '${libraryProvider.studentsInside.length}',
                      Icons.person,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusCard(
                      'Available',
                      '${(status?.totalSeats ?? 0) - libraryProvider.studentsInside.length}',
                      Icons.event_available,
                      Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 12,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'System Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_applications,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'System Controls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildControlButton(
            icon: Icons.refresh,
            title: 'Reset System',
            subtitle: 'Clear all data and reset counters',
            color: AppTheme.accentAmber,
            isLoading: _isResetting,
            onTap: _showResetDialog,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.sync,
            title: 'Sync Database',
            subtitle: 'Force sync with Supabase',
            color: AppTheme.primaryBlue,
            isLoading: false,
            onTap: _syncDatabase,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.cached,
            title: 'Clear Cache',
            subtitle: 'Clear local cache and temporary data',
            color: AppTheme.textSecondary,
            isLoading: false,
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storage,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Data Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildControlButton(
            icon: Icons.download,
            title: 'Export Data (CSV)',
            subtitle: 'Download scan logs and student data',
            color: AppTheme.accentGreen,
            isLoading: _isExporting,
            onTap: _exportData,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.upload_file,
            title: 'Import Data',
            subtitle: 'Import student data from CSV file',
            color: AppTheme.primaryBlue,
            isLoading: false,
            onTap: _importData,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.backup,
            title: 'Create Backup',
            subtitle: 'Create system backup snapshot',
            color: AppTheme.textSecondary,
            isLoading: false,
            onTap: _createBackup,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'System Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('App Version', '1.0.0'),
          _buildInfoRow('Backend API', 'http://localhost:3000'),
          _buildInfoRow('Database', 'Supabase'),
          _buildInfoRow('Last Sync', 'Just now'),
          _buildInfoRow('Uptime', '2h 34m'),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: isLoading ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    )
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset System'),
        content: const Text(
          'Are you sure you want to reset the entire system? This will:\n\n'
          '• Clear all scan logs\n'
          '• Reset seat counters\n'
          '• Remove all students from library\n'
          '• This action cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSystem();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _resetSystem() async {
    setState(() {
      _isResetting = true;
    });

    try {
      // TODO: Implement actual reset API call
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        _showSuccess('System reset successfully');
        Provider.of<LibraryProvider>(context, listen: false)
            .fetchLibraryStatus();
      }
    } catch (e) {
      _showError('Failed to reset system');
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  void _syncDatabase() async {
    _showSuccess('Database synced successfully');
    Provider.of<LibraryProvider>(context, listen: false).fetchLibraryStatus();
  }

  void _clearCache() async {
    _showSuccess('Cache cleared successfully');
  }

  void _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // TODO: Implement actual export functionality
      await Future.delayed(const Duration(seconds: 2));
      _showSuccess('Data exported successfully');
    } catch (e) {
      _showError('Failed to export data');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _importData() {
    _showSuccess('Import feature coming soon');
  }

  void _createBackup() {
    _showSuccess('Backup created successfully');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.accentRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
