import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
  }

  Future<void> _launchWebsite(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Silently fail - website opening is attempted
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
      );
      await launchUrl(emailUri);
    } catch (e) {
      // Silently fail - email opening is attempted
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(phoneUri);
    } catch (e) {
      // Silently fail - phone opening is attempted
    }
  }

  void _clearDatabase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Database',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all records? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (!context.mounted) return;
              Navigator.pop(context);

              if (mounted && context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(dialogContext).colorScheme.primary,
                    ),
                  ),
                );
              }

              await _dbService.deleteAllRecords();

              if (mounted && context.mounted) {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Database cleared successfully',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Section Header
              Text(
                'About',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // About Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('App Name', 'searchit', Icons.title_rounded),
                      const SizedBox(height: 18),
                      _buildDetailRow('Version', '1.1.3', Icons.apps_rounded),
                      const SizedBox(height: 18),
                      _buildDetailRow('Developed By', 'CrafZio', Icons.business_rounded),
                      const SizedBox(height: 18),
                      _buildClickableDetailRow('Email', 'team@crafzio.in', Icons.email_rounded, () => _launchEmail('team@crafzio.in')),
                      const SizedBox(height: 18),
                      _buildClickableDetailRow('Contact', '7026496890', Icons.phone_rounded, () => _launchPhone('7026496890')),
                      const SizedBox(height: 18),
                      _buildClickableDetailRow('Website', 'crafzio.in', Icons.public_rounded, () => _launchWebsite('https://crafzio.in')),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // Database Section Header
              Text(
                'Data Management',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Clear Data Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Danger Zone',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Clearing the database will permanently delete all imported records. This action cannot be undone.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Clear Database Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(
                    'Clear All Data',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _clearDatabase,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // App Info Card
              Card(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Excel Data Search is a powerful local data management tool that allows you to efficiently import, store, and search Excel data directly on your device.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableDetailRow(String label, String value, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}