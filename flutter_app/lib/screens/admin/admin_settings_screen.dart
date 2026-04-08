import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';

/// Admin Settings Screen - System configuration and controls
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _seatsController = TextEditingController();
  bool _isClearing = false;

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.accentAmber,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, child) {
          final status = provider.libraryStatus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // System Status
                _buildSectionCard(
                  title: 'System Status',
                  icon: provider.isSystemOnline ? Icons.check_circle : Icons.error,
                  iconColor: provider.isSystemOnline ? AppTheme.accentGreen : AppTheme.accentRed,
                  children: [
                    ListTile(
                      leading: Icon(
                        provider.isSystemOnline ? Icons.cloud_done : Icons.cloud_off,
                        color: provider.isSystemOnline ? AppTheme.accentGreen : AppTheme.accentRed,
                      ),
                      title: const Text('Connection'),
                      subtitle: Text(provider.isSystemOnline ? 'Connected to Supabase' : 'Offline'),
                    ),
                    if (provider.lastSyncTime != null)
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Last Sync'),
                        subtitle: Text(provider.lastSyncTime!),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Library Configuration
                _buildSectionCard(
                  title: 'Library Configuration',
                  icon: Icons.settings,
                  iconColor: AppTheme.primaryBlue,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.event_seat),
                      title: const Text('Total Seats'),
                      subtitle: Text('Currently: ${status?.totalSeats ?? 0} seats'),
                      trailing: TextButton(
                        onPressed: () => _showUpdateSeatsDialog(context, provider, status?.totalSeats ?? 100),
                        child: const Text('Update'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Current Occupancy'),
                      subtitle: Text('${status?.occupiedSeats ?? 0} students inside'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${status?.occupancyPercentage ?? 0}%',
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // System Actions
                _buildSectionCard(
                  title: 'System Actions',
                  icon: Icons.build,
                  iconColor: AppTheme.accentAmber,
                  children: [
                    ListTile(
                      leading: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                      title: const Text('Refresh Data'),
                      subtitle: const Text('Update all library information'),
                      onTap: () async {
                        await provider.fetchAllData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data refreshed'), backgroundColor: AppTheme.accentGreen),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.restore, color: AppTheme.accentAmber),
                      title: const Text('Reset System'),
                      subtitle: const Text('Mark all students as OUTSIDE'),
                      onTap: () => _showResetDialog(context, provider),
                    ),
                    const Divider(),
                    ListTile(
                      leading: _isClearing
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentRed),
                            )
                          : Icon(Icons.delete_forever, color: AppTheme.accentRed),
                      title: const Text('Clear All Data'),
                      subtitle: const Text('Delete all students and logs (DANGER!)'),
                      onTap: _isClearing ? null : () => _showClearAllDialog(context, provider),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // About
                _buildSectionCard(
                  title: 'About',
                  icon: Icons.info_outline,
                  iconColor: AppTheme.textSecondary,
                  children: [
                    _buildInfoRow('Version', '1.0.0'),
                    _buildInfoRow('Database', 'Supabase PostgreSQL'),
                    _buildInfoRow('API Status', provider.isSystemOnline ? 'Online' : 'Offline'),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showUpdateSeatsDialog(BuildContext context, LibraryProvider provider, int currentSeats) {
    _seatsController.text = currentSeats.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Total Seats'),
        content: TextField(
          controller: _seatsController,
          decoration: const InputDecoration(
            labelText: 'Total Seats',
            hintText: 'Enter number of seats',
            prefixIcon: Icon(Icons.event_seat),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final seats = int.tryParse(_seatsController.text.trim());
              if (seats == null || seats <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number'), backgroundColor: AppTheme.accentRed),
                );
                return;
              }

              Navigator.pop(context);
              final success = await provider.updateLibrarySettings(totalSeats: seats);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Total seats updated to $seats'), backgroundColor: AppTheme.accentGreen),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, LibraryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset System'),
        content: const Text(
          'This will:\n\n'
          '• Mark all students as OUTSIDE\n'
          '• Reset occupied seats to 0\n'
          '• Reset all scan counts\n\n'
          'Student records will be preserved.\n\nAre you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.resetSystem();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('System reset successfully'), backgroundColor: AppTheme.accentGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset failed: $e'), backgroundColor: AppTheme.accentRed),
                  );
                }
              }
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.accentAmber)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, LibraryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.accentRed),
            const SizedBox(width: 8),
            const Text('DANGER!'),
          ],
        ),
        content: const Text(
          'This will PERMANENTLY DELETE:\n\n'
          '• ALL student records\n'
          '• ALL scan history\n\n'
          'This action CANNOT be undone!\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isClearing = true);

              try {
                final success = await provider.clearAllData();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared'), backgroundColor: AppTheme.accentGreen),
                  );
                }
              } finally {
                if (mounted) setState(() => _isClearing = false);
              }
            },
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
