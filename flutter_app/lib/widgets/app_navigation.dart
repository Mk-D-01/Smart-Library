import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_seats_screen.dart';
import '../screens/student/student_history_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/admin/admin_overview_screen.dart';
import '../screens/admin/admin_students_screen.dart';
import '../screens/admin/admin_manual_scanner_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_seat_map_screen.dart';
import '../config/theme_config.dart';
import '../providers/theme_provider.dart';

class AppNavigation extends StatefulWidget {
  final bool isAdmin;
  const AppNavigation({super.key, required this.isAdmin});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;

  late final List<NavigationItem> _studentScreens;
  late final List<NavigationItem> _adminScreens;

  @override
  void initState() {
    super.initState();

    _studentScreens = [
      NavigationItem(
        icon: Icons.home_rounded,
        label: 'Home',
        screen: const StudentDashboardScreen(),
      ),
      NavigationItem(
        icon: Icons.chair_rounded,
        label: 'Seats',
        screen: const StudentSeatsScreen(),
      ),
      NavigationItem(
        icon: Icons.history_rounded,
        label: 'History',
        screen: const StudentHistoryScreen(),
      ),
      NavigationItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        screen: const StudentProfileScreen(),
      ),
    ];

    _adminScreens = [
      NavigationItem(
        icon: Icons.dashboard,
        label: 'Overview',
        screen: AdminOverviewScreen(
          onNavigateToTab: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      NavigationItem(
        icon: Icons.people,
        label: 'Students',
        screen: const AdminStudentsScreen(),
      ),
      NavigationItem(
        icon: Icons.qr_code_scanner,
        label: 'Scanner',
        screen: const AdminManualScannerScreen(),
      ),
      NavigationItem(
        icon: Icons.chair,
        label: 'Seats',
        screen: const AdminSeatMapScreen(),
      ),
      NavigationItem(
        icon: Icons.settings,
        label: 'Settings',
        screen: const AdminSettingsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = widget.isAdmin ? _adminScreens : _studentScreens;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: IndexedStack(
            index: _currentIndex,
            children: screens.map((item) => item.screen).toList(),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
              ),
              items: screens.asMap().entries.map((entry) {
                final item = entry.value;
                return BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
