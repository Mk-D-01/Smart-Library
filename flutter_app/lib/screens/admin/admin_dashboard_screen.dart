import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentAmber,
                          AppTheme.accentAmber.withValues(alpha: 0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Library Management',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout_rounded,
                              color: AppTheme.accentRed, size: 20),
                          tooltip: 'Logout',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OverviewTab(),
                  StudentsTab(),
                  ScannerTab(),
                  ActivityTab(),
                  SettingsTab(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: AppTheme.accentAmber,
                indicatorWeight: 3,
                labelColor: AppTheme.accentAmber,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                isScrollable: true,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
                  Tab(icon: Icon(Icons.people_rounded), text: 'Students'),
                  Tab(
                      icon: Icon(Icons.qr_code_scanner_rounded),
                      text: 'Scanner'),
                  Tab(icon: Icon(Icons.history_rounded), text: 'Activity'),
                  Tab(icon: Icon(Icons.settings_rounded), text: 'Settings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              Navigator.pop(dialogContext);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                nav.pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = provider.libraryStatus;
        if (status == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: status.occupancyPercentage >= 80
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : status.occupancyPercentage >= 50
                            ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                            : [
                                const Color(0xFF10B981),
                                const Color(0xFF059669)
                              ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.medium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          status.occupancyPercentage >= 80
                              ? Icons.warning
                              : status.occupancyPercentage >= 50
                                  ? Icons.people
                                  : Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${status.occupancyPercentage.toStringAsFixed(0)}% Occupied',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'Total Seats',
                    '${status.totalSeats}',
                    Icons.event_seat,
                    AppTheme.primaryBlue,
                  ),
                  _buildStatCard(
                    context,
                    'Occupied',
                    '${provider.studentsInside.length}',
                    Icons.person,
                    AppTheme.accentAmber,
                  ),
                  _buildStatCard(
                    context,
                    'Available',
                    '${status.totalSeats - provider.studentsInside.length}',
                    Icons.check_circle,
                    AppTheme.accentGreen,
                  ),
                  _buildStatCard(
                    context,
                    'Students Inside',
                    '${provider.studentsInside.length}',
                    Icons.people,
                    AppTheme.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  bool _showAllStudents = false;
  List<dynamic> _allStudents = [];
  bool _isLoadingAll = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(color: AppTheme.divider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Inside Now'),
                          icon: Icon(Icons.person),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('All Students'),
                          icon: Icon(Icons.people),
                        ),
                      ],
                      selected: {_showAllStudents},
                      onSelectionChanged: (Set<bool> selected) {
                        setState(() {
                          _showAllStudents = selected.first;
                          if (_showAllStudents && _allStudents.isEmpty) {
                            _loadAllStudents(provider);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _showAddStudentDialog(context, provider),
                    icon: const Icon(Icons.person_add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Add Student',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showAllStudents
                  ? _buildAllStudentsList(provider)
                  : _buildInsideStudentsList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsideStudentsList(LibraryProvider provider) {
    final students = provider.studentsInside;

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No students inside',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Library is empty',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  student.id.length >= 3
                      ? student.id.substring(student.id.length - 3)
                      : student.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(student.name),
              subtitle: Text('ID: ${student.id}'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'INSIDE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllStudentsList(LibraryProvider provider) {
    if (_isLoadingAll) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No students registered',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(context, provider),
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Student'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAllStudents(provider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allStudents.length,
        itemBuilder: (context, index) {
          final student = _allStudents[index];
          final isInside = student.currentStatus == 'INSIDE';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor:
                    isInside ? AppTheme.accentGreen : AppTheme.textSecondary,
                child: Text(
                  student.id.length >= 3
                      ? student.id.substring(student.id.length - 3)
                      : student.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(student.name),
              subtitle: Text('ID: ${student.id} • Scans: ${student.scanCount}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isInside
                          ? AppTheme.accentGreen
                          : AppTheme.textSecondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.currentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.accentRed, size: 20),
                    onPressed: () =>
                        _confirmDeleteStudent(context, provider, student.id),
                    tooltip: 'Delete student',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadAllStudents(LibraryProvider provider) async {
    setState(() {
      _isLoadingAll = true;
    });

    try {
      final students = await provider.getAllStudents();
      setState(() {
        _allStudents = students;
      });
    } catch (e) {
      debugPrint('Error loading all students: $e');
    } finally {
      setState(() {
        _isLoadingAll = false;
      });
    }
  }

  void _showAddStudentDialog(BuildContext context, LibraryProvider provider) {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Student ID *',
                hintText: 'Enter 11-digit ID',
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              maxLength: 11,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name (Optional)',
                hintText: 'Enter student name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              final name = nameController.text.trim();

              if (!RegExp(r'^\d{11}$').hasMatch(id)) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Student ID must be exactly 11 digits'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final result = await provider.addStudent(id,
                  name: name.isEmpty ? null : name);

              final message = result != null
                  ? 'Student added successfully'
                  : 'Failed to add student. May already exist.';
              final color = result != null
                  ? AppTheme.accentGreen
                  : AppTheme.accentRed;
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: color),
                );
                if (result != null && _showAllStudents) {
                  _loadAllStudents(provider);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(
      BuildContext context, LibraryProvider provider, String studentId) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
            'Are you sure you want to delete student $studentId?\n\nThis will also delete all their scan history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.deleteStudent(studentId);
              final message = success
                  ? 'Student deleted successfully'
                  : 'Failed to delete student';
              final color = success
                  ? AppTheme.accentGreen
                  : AppTheme.accentRed;
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: color),
                );
                if (success) {
                  _loadAllStudents(provider);
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}

class ScannerTab extends StatelessWidget {
  const ScannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Scanner Tab'),
    );
  }
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Activity Tab'),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Tab'),
    );
  }
}
