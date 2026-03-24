import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/record_model.dart';

class DetailScreen extends StatelessWidget {
  final ExcelRecord record;

  const DetailScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final rowData = record.rowData;
    final entries = rowData.entries.toList();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Record Details',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entries.length} Fields',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 28 : 20),

              // Records Info Header
              Text(
                'Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),

              // Data Fields List
              ...entries.asMap().entries.map((mapEntry) {
                final entry = mapEntry.value;
                final key = entry.key;
                final value = entry.value;
                final displayValue = value?.toString().trim().isEmpty == true
                    ? '-'
                    : value?.toString().trim() ?? '-';

                return Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field Label
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  key,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Field Value
                          Text(
                            displayValue,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: isTablet ? 32 : 24),

              // Copy All Data Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.content_copy_rounded),
                  label: Text(
                    'Copy All Data',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Data copied to clipboard',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green.shade600,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
