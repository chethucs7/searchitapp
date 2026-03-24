import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _scheduleNavigation();
  }

  /// Navigate after splash duration using post-frame callback
  void _scheduleNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final logoSize = isLandscape ? 100.0 : 140.0;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF6366F1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo (No Animation)
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.blue.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_rounded,
                size: logoSize * 0.5,
                color: const Color(0xFF4F46E5),
              ),
            ),
            SizedBox(height: logoSize * 0.3),
            
            // App Name
            Text(
              'Excel Data Search',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isLandscape ? 24 : 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Smart Local Excel Search',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isLandscape ? 12 : 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: logoSize * 0.3),
            
            // Loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.9),
                ),
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: logoSize * 0.4),
            
            // Developer Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Developed by CrafZio',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isLandscape ? 11 : 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'team@crafzio.com',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isLandscape ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
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
}
