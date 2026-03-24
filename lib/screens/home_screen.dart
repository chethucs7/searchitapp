import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/excel_service.dart';
import '../models/record_model.dart';
import 'search_screen.dart';
import 'database_overview_screen.dart';
import 'performance_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _recordCount = 0;
  bool _isLoading = true;
  bool _isProcessing = false;
  late DatabaseService _dbService;
  int _importProgress = 0;
  int _totalImportRecords = 0;
  late StateSetter _dialogSetState;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _loadRecordCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecordCount();
  }

  Future<void> _loadRecordCount() async {
    try {
      final count = await _dbService.getRecordCount();
      if (mounted) {
        setState(() {
          _recordCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadExcel() async {
    try {
      const XTypeGroup excelTypeGroup = XTypeGroup(
        label: 'Excel',
        extensions: <String>['xlsx', 'xls'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[excelTypeGroup],
      );

      if (file == null) return;

      final filePath = file.path;

      // Validate file before import
      final isValid = await ExcelService.isValidExcelFile(filePath);
      if (!isValid) {
        if (!mounted) return;
        _showErrorDialog('Invalid Excel file or file size exceeds 100MB');
        return;
      }

      if (!mounted) return;
      _showImportProgressDialog();

      final startTime = DateTime.now();

      try {
        // Parse Excel in background isolate (non-blocking)
        final records = await compute(
          ExcelService.readExcelFileAsync,
          filePath,
        );

        if (!mounted) return;

        if (records.isEmpty) {
          _isDialogOpen = false;
          if (mounted) Navigator.of(context).pop();
          _showErrorDialog('No valid data found in Excel file');
          return;
        }

        _totalImportRecords = records.length;

        // Ultra-fast batch insertion
        await _insertRecordsUltraFast(records);

        if (!mounted) return;
        
        _isDialogOpen = false;

        if (mounted) Navigator.of(context).pop();

        await _loadRecordCount();

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        _showSuccessDialog(
          'Import Complete ✓\n\n'
          '📊 Records: ${records.length}\n'
          '⏱️ Time: ${duration.inSeconds}s\n\n'
          'All records imported successfully!',
        );
      } catch (e) {
        if (mounted) {
          _isDialogOpen = false;
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          _showErrorDialog('Error: ${e.toString()}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
      }
    }
  }

  /// Ultra-fast record insertion with real-time progress
  Future<void> _insertRecordsUltraFast(List<ExcelRecord> records) async {
    const int batchSize = 500;
    final int totalBatches = (records.length / batchSize).ceil();
    int processedRows = 0;

    for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
      final start = batchIndex * batchSize;
      final end = (start + batchSize > records.length)
          ? records.length
          : start + batchSize;

      final batch = records.sublist(start, end);

      // Insert batch in transaction
      await _dbService.insertRecords(batch);

      processedRows = end;

      // Update progress for every batch
      _importProgress = processedRows;

      // Call dialog's setState to update UI in real-time
      if (mounted && _isDialogOpen) {
        _dialogSetState(() {});
      }

      // Minimal delay - keeps UI responsive without blocking
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Ensure final progress is complete
    _importProgress = records.length;
    if (mounted && _isDialogOpen) {
      _dialogSetState(() {});
    }
  }

  void _showImportProgressDialog() {
    _importProgress = 0;
    _totalImportRecords = 0;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          _dialogSetState = setState; // Capture dialog's setState
          return AlertDialog(
          title: Text(
            'Importing Excel File',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Progress bar with smooth animation
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _totalImportRecords > 0 
                      ? (_importProgress / _totalImportRecords).clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Percentage display (0-100)
              Text(
                _totalImportRecords > 0
                    ? '${((_importProgress / _totalImportRecords) * 100).toStringAsFixed(1)}%'
                    : '0%',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Status details with current row progress
              Text(
                _totalImportRecords > 0
                    ? 'Processing $_importProgress of $_totalImportRecords records'
                    : 'Preparing import...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Animated spinner
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade50,
                ),
                child: Text(
                  '⏳ Processing your file...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Success',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Processing',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Processing Excel file...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait, this may take a few moments',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadRecordCount(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
              child: Column(
                children: [
                  // Records Count Card with Gradient
                  Card(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      child: Column(
                        children: [
                          Text(
                            'Records Imported',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _recordCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: isLandscape ? 48 : 56,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 3,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(
                        'Upload Excel File',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _uploadExcel,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),

                  // Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50,
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Guide',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _recordCount > 0
                                      ? 'Ready to search! Go to Search tab'
                                      : 'Upload an Excel file to get started',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),

                  // Features Grid
                  Text(
                    'Features',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isLandscape ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildFeatureTile(
                        icon: Icons.upload_rounded,
                        label: 'Import',
                        color: Colors.blue,
                        onTap: _uploadExcel,
                      ),
                      _buildFeatureTile(
                        icon: Icons.search_rounded,
                        label: 'Search',
                        color: Colors.purple,
                        onTap: () => _navigateToSearch(),
                      ),
                      _buildFeatureTile(
                        icon: Icons.storage_rounded,
                        label: 'Database',
                        color: Colors.orange,
                        onTap: () => _navigateToDatabase(),
                      ),
                      _buildFeatureTile(
                        icon: Icons.speed_rounded,
                        label: 'Fast',
                        color: Colors.green,
                        onTap: () => _navigateToPerformance(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearch() {
    // Navigate to search tab with auto-focused search bar
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchScreenNavigator(),
      ),
    );
  }

  void _navigateToDatabase() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DatabaseOverviewScreen(),
      ),
    );
  }

  void _navigateToPerformance() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PerformanceInfoScreen(),
      ),
    );
  }
}

// Search Screen wrapper to handle auto-focus
class SearchScreenNavigator extends StatefulWidget {
  const SearchScreenNavigator({super.key});

  @override
  State<SearchScreenNavigator> createState() => _SearchScreenNavigatorState();
}

class _SearchScreenNavigatorState extends State<SearchScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return const SearchScreenWithAutoFocus();
  }
}
