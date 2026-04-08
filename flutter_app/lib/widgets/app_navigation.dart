import 'package:flutter/material.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/student/student_history_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_students_inside_screen.dart';
import '../screens/admin/admin_scanner_screen.dart';
import '../screens/admin/admin_controls_screen.dart';
import '../config/theme_config.dart';

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
        icon: Icons.home,
        label: 'Home',
        screen: const StudentHomeScreen(),
      ),
      NavigationItem(
        icon: Icons.history,
        label: 'History',
        screen: const StudentHistoryScreen(),
      ),
      NavigationItem(
        icon: Icons.person,
        label: 'Profile',
        screen: const StudentProfileScreen(),
      ),
    ];

    _adminScreens = [
      NavigationItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        screen: const AdminDashboardScreen(),
      ),
      NavigationItem(
        icon: Icons.people,
        label: 'Students',
        screen: const AdminStudentsInsideScreen(),
      ),
      NavigationItem(
        icon: Icons.qr_code_scanner,
        label: 'Scanner',
        screen: const AdminScannerScreen(),
      ),
      NavigationItem(
        icon: Icons.settings,
        label: 'Controls',
        screen: const AdminControlsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = widget.isAdmin ? _adminScreens : _studentScreens;
    
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
