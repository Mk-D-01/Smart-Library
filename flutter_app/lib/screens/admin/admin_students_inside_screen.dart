import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../config/theme_config.dart';
import '../../models/student.dart';

class AdminStudentsInsideScreen extends StatefulWidget {
  const AdminStudentsInsideScreen({super.key});

  @override
  State<AdminStudentsInsideScreen> createState() =>
      _AdminStudentsInsideScreenState();
}

class _AdminStudentsInsideScreenState extends State<AdminStudentsInsideScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));

    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false)
          .fetchStudentsInside();
    });

    // Start auto-refresh animation
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshController.repeat();
    // Refresh data every 5 seconds
    Stream.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        Provider.of<LibraryProvider>(context, listen: false)
            .fetchStudentsInside();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.people, size: 24),
            const SizedBox(width: 12),
            const Text('Students Inside'),
            const Spacer(),
            AnimatedBuilder(
              animation: _refreshAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshAnimation.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          final studentsInside = libraryProvider.studentsInside;

          return Column(
            children: [
              _buildHeader(studentsInside.length),
              Expanded(
                child: studentsInside.isEmpty
                    ? _buildEmptyState()
                    : _buildStudentsList(studentsInside),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(int studentCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.blueGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$studentCount students',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Updated just now • Auto-refresh every 5 seconds',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.no_meeting_room,
              size: 60,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Students Inside',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Library is currently empty',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Student Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(List<Student> students) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<LibraryProvider>(context, listen: false)
            .fetchStudentsInside();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return _buildStudentCard(student);
        },
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final duration = _calculateDuration((student.updatedAt?.toIso8601String() ??
        DateTime.now().toIso8601String()));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.blueGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.id,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'INSIDE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entry: ${_formatTime((student.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String()))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Duration: $duration',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showForceExitDialog(student),
                  icon: const Icon(Icons.exit_to_app, size: 16),
                  label: const Text('Force Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentAmber,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDuration(String entryTime) {
    try {
      final entry = DateTime.parse(entryTime);
      final now = DateTime.now();
      final difference = now.difference(entry);

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _showForceExitDialog(Student student) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Force Exit'),
        content: Text(
          'Force exit ${student.name} (${student.id}) from the library?\n\nThis will update their status to OUTSIDE, log an EXIT scan, and decrement occupied seats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Force Exit',
              style: TextStyle(color: AppTheme.accentAmber),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.forceExitStudent(student.id,
          studentName: student.name);
      final message = success
          ? '${student.name} force exited successfully'
          : 'Failed to force exit student';
      final color = success ? AppTheme.accentGreen : AppTheme.accentRed;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAddStudentDialog() {
    // TODO: Implement add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add student feature coming soon'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}
