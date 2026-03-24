import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class DatabaseOverviewScreen extends StatefulWidget {
  const DatabaseOverviewScreen({super.key});

  @override
  State<DatabaseOverviewScreen> createState() => _DatabaseOverviewScreenState();
}

class _DatabaseOverviewScreenState extends State<DatabaseOverviewScreen> {
  late DatabaseService _dbService;
  int _totalRecords = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    try {
      final count = await _dbService.getRecordCount();
      if (mounted) {
        setState(() {
          _totalRecords = count;
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database Overview',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Records Card
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.storage_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Records',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _totalRecords.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Database Info Section
                    Text(
                      'Database Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Cards
                    _buildInfoCard(
                      icon: Icons.library_books_rounded,
                      title: 'Database Type',
                      value: 'SQLite',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.storage_rounded,
                      title: 'Storage Location',
                      value: 'Local Device',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Status',
                      value: _totalRecords > 0 ? 'Active' : 'Empty',
                      color: _totalRecords > 0 ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.speed_rounded,
                      title: 'Last Action',
                      value: _totalRecords > 0 ? 'Records Imported' : 'No imports yet',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 24),

                    // Stats Section
                    Text(
                      'Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Records',
                            value: _totalRecords.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Status',
                            value: _totalRecords > 0 ? '✓' : '○',
                            color: _totalRecords > 0 ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
