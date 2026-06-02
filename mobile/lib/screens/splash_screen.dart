import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../core/constants/colors.dart';
import '../providers/auth_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 3 seconds of branding
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isPaired) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const HomeScreen(),
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const OnboardingScreen(),
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CypherColors.primaryBackground,
      body: Stack(
        children: [
          // Background subtle pattern or glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CypherColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 1200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CypherColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: CypherColors.primary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: CypherColors.primary.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: CypherColors.primary,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: const Text(
                    'CYPHER',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    'SECURE LOCAL CONTROL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                      color: CypherColors.secondaryText.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CypherColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
