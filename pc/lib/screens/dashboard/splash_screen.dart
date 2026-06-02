import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import 'dashboard_screen.dart';

class PCSplashScreen extends StatefulWidget {
  const PCSplashScreen({super.key});

  @override
  State<PCSplashScreen> createState() => _PCSplashScreenState();
}

class _PCSplashScreenState extends State<PCSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const DashboardScreen(),
            transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CypherColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: CypherColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: CypherColors.primary.withOpacity(0.1)),
                ),
                child: const Icon(Icons.security_rounded, color: CypherColors.primary, size: 100),
              ),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: const Text(
                'CYPHER PC',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            FadeIn(
              delay: const Duration(milliseconds: 800),
              child: Text(
                'PRODUCTION GRADE SECURE ACCESS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 4, color: CypherColors.secondaryText.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
