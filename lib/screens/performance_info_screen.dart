import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerformanceInfoScreen extends StatelessWidget {
  const PerformanceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Performance Info',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
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
                            child: const Icon(
                              Icons.speed_rounded,
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
                                  'Fast & Efficient',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Optimized Search',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
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

              // Search Performance
              _buildSectionTitle('Search Performance'),
              const SizedBox(height: 16),

              _buildPerformanceCard(
                icon: Icons.flash_on_rounded,
                title: 'Instant Search',
                description: 'Real-time filtering with instant results as you type',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              _buildPerformanceCard(
                icon: Icons.trending_up_rounded,
                title: 'Optimized Queries',
                description: 'Efficient database queries for lightning-fast results',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              _buildPerformanceCard(
                icon: Icons.memory_rounded,
                title: 'Low Memory Usage',
                description: 'Minimal memory footprint with smart caching',
                color: Colors.purple,
              ),
              const SizedBox(height: 24),

              // Excel Optimization
              _buildSectionTitle('Excel Optimization'),
              const SizedBox(height: 16),

              _buildPerformanceCard(
                icon: Icons.upload_file_rounded,
                title: 'Batch Import',
                description: 'Efficiently import large Excel files in batches',
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _buildPerformanceCard(
                icon: Icons.table_rows_rounded,
                title: 'Smart Parsing',
                description: 'Intelligent row parsing with automatic data validation',
                color: Colors.teal,
              ),
              const SizedBox(height: 12),

              _buildPerformanceCard(
                icon: Icons.check_circle_rounded,
                title: 'Data Integrity',
                description: 'Ensures accurate data import without corruption',
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),

              // Features
              _buildSectionTitle('Key Features'),
              const SizedBox(height: 16),

              _buildFeatureItem('⚡ Lightning-fast search across thousands of records'),
              const SizedBox(height: 12),
              _buildFeatureItem('📊 Optimized database storage'),
              const SizedBox(height: 12),
              _buildFeatureItem('🔄 Smooth real-time filtering'),
              const SizedBox(height: 12),
              _buildFeatureItem('💾 Efficient memory management'),
              const SizedBox(height: 12),
              _buildFeatureItem('✅ Reliable data handling'),
              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pro Tip',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For best performance, organize your Excel data with clear headers',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required String title,
    required String description,
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
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
    );
  }

  Widget _buildFeatureItem(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
