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
    
    // Initialize library provider if not already done
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
            // App Bar
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
                        colors: [AppTheme.accentAmber, AppTheme.accentAmber.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
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
                          icon: Icon(Icons.logout_rounded, color: AppTheme.accentRed, size: 20),
                          tooltip: 'Logout',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Content
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
            
            // Bottom Navigation
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
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                isScrollable: true,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
                  Tab(icon: Icon(Icons.people_rounded), text: 'Students'),
                  Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Scanner'),
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
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
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
              // Status Card
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
                            : [const Color(0xFF10B981), const Color(0xFF059669)],
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      '${status.occupancyPercentage.toStringAsFixed(1)}% Occupied',
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
              
              // Stats Grid
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
                    '${status.occupiedSeats}',
                    Icons.person,
                    AppTheme.accentAmber,
                  ),
                  _buildStatCard(
                    context,
                    'Available',
                    '${status.availableSeats}',
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
            style: TextStyle(
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
            // Header with toggle and add button
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
            
            // Student list
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
                  student.id.length >= 3 ? student.id.substring(student.id.length - 3) : student.id,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                backgroundColor: isInside ? AppTheme.accentGreen : AppTheme.textSecondary,
                child: Text(
                  student.id.length >= 3 ? student.id.substring(student.id.length - 3) : student.id,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isInside ? AppTheme.accentGreen : AppTheme.textSecondary,
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
                    icon: Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 20),
                    onPressed: () => _confirmDeleteStudent(context, provider, student.id),
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              final name = nameController.text.trim();
              
              if (!RegExp(r'^\d{11}$').hasMatch(id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student ID must be exactly 11 digits'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final result = await provider.addStudent(id, name: name.isEmpty ? null : name);
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student added successfully'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
                if (_showAllStudents) {
                  _loadAllStudents(provider);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to add student. May already exist.'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(BuildContext context, LibraryProvider provider, String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete student $studentId?\n\nThis will also delete all their scan history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteStudent(studentId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student deleted successfully'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
                _loadAllStudents(provider);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete student'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}

class ScannerTab extends StatefulWidget {
  const ScannerTab({super.key});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> {
  final TextEditingController _studentIdController = TextEditingController();
  bool _isScanning = false;
  String? _lastScanResult;
  bool? _wasEntry;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Manual Entry Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.keyboard, color: AppTheme.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Manual Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter student ID manually when hardware scanner is unavailable',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      hintText: 'Enter 11-digit Student ID',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _processScan,
                      icon: _isScanning 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner),
                      label: Text(_isScanning ? 'Processing...' : 'Process Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Last Scan Result
          if (_lastScanResult != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: _wasEntry == true ? AppTheme.accentGreen.withValues(alpha: 0.1) : AppTheme.accentRed.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _wasEntry == true ? Icons.login : Icons.logout,
                      size: 48,
                      color: _wasEntry == true ? AppTheme.accentGreen : AppTheme.accentRed,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _wasEntry == true ? 'ENTRY' : 'EXIT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _wasEntry == true ? AppTheme.accentGreen : AppTheme.accentRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastScanResult!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Instructions
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.accentAmber, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'How Scanning Works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem('1', 'Single scanner handles both ENTRY and EXIT'),
                  _buildInstructionItem('2', 'System uses odd/even logic to determine action'),
                  _buildInstructionItem('3', 'First scan = Entry, Second scan = Exit, and so on'),
                  _buildInstructionItem('4', 'New students are automatically registered'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processScan() async {
    final studentId = _studentIdController.text.trim();
    
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a student ID'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(studentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student ID must be exactly 11 digits'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      final result = await provider.processScan(studentId);
      
      if (result != null) {
        final isEntry = result.action == 'ENTRY';
        setState(() {
          _wasEntry = isEntry;
          _lastScanResult = 'Student $studentId - ${isEntry ? "Entered" : "Exited"} the library';
        });
        _studentIdController.clear();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEntry ? 'Entry recorded successfully' : 'Exit recorded successfully'),
              backgroundColor: isEntry ? AppTheme.accentGreen : AppTheme.accentAmber,
            ),
          );
        }
      } else {
        throw Exception('Scan failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = provider.scanLogs;
        if (logs.isEmpty) {
          return const Center(child: Text('No activity available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: log.isEntry ? AppTheme.accentGreen : AppTheme.accentRed,
                  child: Icon(
                    log.isEntry ? Icons.login : Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text('Student ${log.studentId}'),
                subtitle: Text('${log.relativeTime} • ${log.formattedTime}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: log.isEntry ? AppTheme.accentGreen : AppTheme.accentRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.scanType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final TextEditingController _seatsController = TextEditingController();
  bool _isClearing = false;

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        final status = provider.libraryStatus;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.isSystemOnline ? Icons.check_circle : Icons.error,
                            color: provider.isSystemOnline ? AppTheme.accentGreen : AppTheme.accentRed,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'System Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isSystemOnline ? 'Online and Connected to Supabase' : 'Offline or Error',
                        style: TextStyle(
                          fontSize: 14,
                          color: provider.isSystemOnline ? AppTheme.accentGreen : AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Library Configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            'Library Configuration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build, color: AppTheme.accentAmber),
                          const SizedBox(width: 12),
                          Text(
                            'System Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                        title: const Text('Refresh Data'),
                        subtitle: const Text('Update all library information'),
                        onTap: () async {
                          await provider.fetchAllData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data refreshed successfully'),
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.restore, color: AppTheme.accentAmber),
                        title: const Text('Reset System'),
                        subtitle: const Text('Mark all students as OUTSIDE, reset occupancy'),
                        onTap: () => _showResetDialog(context, provider),
                      ),
                      const Divider(),
                      ListTile(
                        leading: _isClearing 
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentRed,
                                ),
                              )
                            : Icon(Icons.delete_forever, color: AppTheme.accentRed),
                        title: const Text('Clear All Data'),
                        subtitle: const Text('Delete all students and logs (DANGER!)'),
                        onTap: _isClearing ? null : () => _showClearAllDialog(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // About
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Version', '1.0.0'),
                      _buildInfoRow('Database', 'Supabase PostgreSQL'),
                      _buildInfoRow('Last Sync', provider.lastSyncTime ?? 'Never'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final seats = int.tryParse(_seatsController.text.trim());
              if (seats == null || seats <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              final success = await provider.updateLibrarySettings(totalSeats: seats);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Total seats updated to $seats'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update seats'),
                    backgroundColor: AppTheme.accentRed,
                  ),
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
          'Student records and history will be preserved.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.resetSystem();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('System reset successfully'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reset failed: $e'),
                      backgroundColor: AppTheme.accentRed,
                    ),
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
          '• ALL scan history\n'
          '• Reset library to empty state\n\n'
          'This action CANNOT be undone!\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isClearing = true;
              });
              
              try {
                final success = await provider.clearAllData();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to clear data'),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isClearing = false;
                  });
                }
              }
            },
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );
  }
}
