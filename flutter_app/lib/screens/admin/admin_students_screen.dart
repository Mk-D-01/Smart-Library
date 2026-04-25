import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/library_provider.dart';
import '../../models/student.dart';

/// Admin Students Screen - Manage students
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  bool _showAllStudents = false;
  List<Student> _allStudents = [];
  bool _isLoadingAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: AppTheme.accentAmber,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showAddStudentDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
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
                    _loadAllStudents();
                  }
                });
              },
            ),
          ),
          // Student List
          Expanded(
            child: _showAllStudents
                ? _buildAllStudentsList()
                : _buildInsideStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsideStudentsList() {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text('Library is empty', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAllData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) => _buildStudentCard(students[index], true),
          ),
        );
      },
    );
  }

  Widget _buildAllStudentsList() {
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Student'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAllStudents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allStudents.length,
        itemBuilder: (context, index) => _buildStudentCard(_allStudents[index], false),
      ),
    );
  }

  Widget _buildStudentCard(Student student, bool showInsideOnly) {
    final isInside = student.currentStatus == 'INSIDE';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isInside ? AppTheme.accentGreen : AppTheme.textSecondary,
          child: Text(
            student.id.length >= 3 ? student.id.substring(student.id.length - 3) : student.id,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
            if (!showInsideOnly) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 20),
                onPressed: () => _confirmDeleteStudent(context, student.id),
                tooltip: 'Delete student',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadAllStudents() async {
    setState(() => _isLoadingAll = true);
    try {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      final students = await provider.getAllStudents();
      setState(() => _allStudents = students);
    } catch (e) {
      debugPrint('Error loading all students: $e');
    } finally {
      setState(() => _isLoadingAll = false);
    }
  }

  void _showAddStudentDialog(BuildContext context) {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

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
              final provider = Provider.of<LibraryProvider>(context, listen: false);
              final result = await provider.addStudent(id, name: name.isEmpty ? null : name);
              final message = result == null
                  ? 'Failed to add student. May already exist.'
                  : 'Student added successfully';
              final color = result == null ? AppTheme.accentRed : AppTheme.accentGreen;
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text(message), backgroundColor: color),
              );
              if (result != null && _showAllStudents) _loadAllStudents();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(BuildContext context, String studentId) {
    final messenger = ScaffoldMessenger.of(context);
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
              final provider = Provider.of<LibraryProvider>(context, listen: false);
              final success = await provider.deleteStudent(studentId);
              final message = success
                  ? 'Student deleted successfully'
                  : 'Failed to delete student';
              final color = success ? AppTheme.accentGreen : AppTheme.accentRed;
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text(message), backgroundColor: color),
              );
              if (success) _loadAllStudents();
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
