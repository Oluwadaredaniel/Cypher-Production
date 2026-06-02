import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';

class ConnectionLostScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const ConnectionLostScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CypherColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CypherColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 80, color: CypherColors.error),
            ),
            const SizedBox(height: 40),
            const Text(
              'Connection Lost',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'We lost track of your PC. Ensure the Cypher app is running and your WiFi is active.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CypherColors.secondaryText, height: 1.5),
            ),
            const SizedBox(height: 48),
            CustomButton(text: 'Try Reconnecting', onPressed: onRetry),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back', style: TextStyle(color: CypherColors.tertiaryText)),
            ),
          ],
        ),
      ),
    );
  }
}
