import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ControlsTab extends StatelessWidget {
  const ControlsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mouse_rounded, size: 64, color: CypherColors.tertiaryText),
          SizedBox(height: 16),
          Text(
            'Remote Controls Active',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Your PC is ready to receive commands from paired mobile devices.',
            style: TextStyle(color: CypherColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
