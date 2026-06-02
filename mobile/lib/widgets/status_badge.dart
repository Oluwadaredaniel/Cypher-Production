import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class StatusBadge extends StatelessWidget {
  final ConnectionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ConnectionStatus.connected:
        color = CypherColors.success;
        text = 'Connected';
        break;
      case ConnectionStatus.connecting:
        color = CypherColors.warning;
        text = 'Connecting';
        break;
      case ConnectionStatus.disconnected:
        color = CypherColors.tertiaryText;
        text = 'Disconnected';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (status == ConnectionStatus.connected)
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
