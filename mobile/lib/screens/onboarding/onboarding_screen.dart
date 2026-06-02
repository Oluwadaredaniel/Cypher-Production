import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import 'discovery_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Total Control',
      desc: 'Manage your PC power, media, and apps directly from your phone.',
      icon: Icons.settings_remote_outlined,
    ),
    OnboardingData(
      title: 'Seamless Sync',
      desc: 'Transfer files and sync clipboards instantly across your local network.',
      icon: Icons.sync_alt_rounded,
    ),
    OnboardingData(
      title: 'Local & Secure',
      desc: '100% local communication. Your data never leaves your network.',
      icon: Icons.lock_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          child: Icon(_pages[index].icon, size: 120, color: CypherColors.primary),
                        ),
                        const SizedBox(height: 60),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            _pages[index].title,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                            textAlign: Center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            _pages[index].desc,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? CypherColors.primary : CypherColors.tertiaryText,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomButton(
                    text: _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscoveryScreen()));
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      }
                    },
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

class OnboardingData {
  final String title;
  final String desc;
  final IconData icon;

  OnboardingData({required this.title, required this.desc, required this.icon});
}
