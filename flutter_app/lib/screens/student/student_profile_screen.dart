import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../models/user.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load from SharedPreferences
    setState(() {
      _darkMode = false; // Default
      _notifications = true; // Default
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.blueGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Student',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.id ?? 'STU001',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role.name.toUpperCase() ?? 'STUDENT',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Toggle dark theme',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // TODO: Implement theme switching
            },
          ),
          Divider(color: AppTheme.dividerColor),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable push notifications',
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
              // TODO: Implement notification settings
            },
          ),
          Divider(color: AppTheme.dividerColor),
          ListTile(
            leading: const Icon(
              Icons.refresh,
              color: AppTheme.primaryBlue,
            ),
            title: Text(
              'Refresh Data',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Sync latest library data',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement data refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data refreshed successfully'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Version', '1.0.0'),
          _buildInfoItem('Build', '2025.04.06'),
          _buildInfoItem('Developer', 'Smart Library Team'),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Show about dialog
              },
              child: const Text(
                'About',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
