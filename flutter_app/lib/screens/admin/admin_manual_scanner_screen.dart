import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/library_provider.dart';

/// Admin Scanner Screen - Manual entry for scanning students
class AdminManualScannerScreen extends StatefulWidget {
  const AdminManualScannerScreen({super.key});

  @override
  State<AdminManualScannerScreen> createState() =>
      _AdminManualScannerScreenState();
}

class _AdminManualScannerScreenState extends State<AdminManualScannerScreen> {
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: AppTheme.accentAmber,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Manual Entry Card
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.keyboard,
                            color: AppTheme.primaryBlue, size: 24),
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
                      'Enter student ID manually or use camera to scan student QR code',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        hintText: 'Enter 11-digit Student ID',
                        prefixIcon: const Icon(Icons.badge),
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12))),
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
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.qr_code_scanner),
                        label: Text(
                            _isScanning ? 'Processing...' : 'Process Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                color: _wasEntry == true
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : AppTheme.accentRed.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _wasEntry == true ? Icons.login : Icons.logout,
                        size: 48,
                        color: _wasEntry == true
                            ? AppTheme.accentGreen
                            : AppTheme.accentRed,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _wasEntry == true ? 'ENTRY' : 'EXIT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _wasEntry == true
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastScanResult!,
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Recent Scans
            Consumer<LibraryProvider>(
              builder: (context, provider, child) {
                final recentLogs = provider.scanLogs.take(5).toList();

                return Card(
                  elevation: 1,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Scans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (recentLogs.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No recent scans',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                            ),
                          )
                        else
                          ...recentLogs.map((log) => _buildRecentScanItem(log)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.accentAmber, size: 24),
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
                    _buildInstructionItem(
                        '1', 'Single scanner handles both ENTRY and EXIT'),
                    _buildInstructionItem(
                        '2', 'System uses odd/even logic to determine action'),
                    _buildInstructionItem('3',
                        'First scan = Entry, Second scan = Exit, and so on'),
                    _buildInstructionItem(
                        '4', 'New students are automatically registered'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScanItem(dynamic log) {
    final isEntry = log.isEntry;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isEntry ? AppTheme.accentGreen : AppTheme.accentAmber)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(isEntry ? Icons.login : Icons.logout,
              color: isEntry ? AppTheme.accentGreen : AppTheme.accentAmber,
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.studentId,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(log.relativeTime,
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEntry ? AppTheme.accentGreen : AppTheme.accentAmber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEntry ? 'IN' : 'OUT',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
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
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
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
            backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(studentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Student ID must be exactly 11 digits'),
            backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    setState(() => _isScanning = true);

    try {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      final result = await provider.processScan(studentId);

      final isEntry = result.action == 'ENTRY';
      setState(() {
        _wasEntry = isEntry;
        _lastScanResult =
            'Student $studentId - ${isEntry ? "Entered" : "Exited"} the library';
      });
      _studentIdController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEntry
                ? 'Entry recorded successfully'
                : 'Exit recorded successfully'),
            backgroundColor:
                isEntry ? AppTheme.accentGreen : AppTheme.accentAmber,
          ),
        );
      }
        } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Scan failed: $e'),
              backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
}
