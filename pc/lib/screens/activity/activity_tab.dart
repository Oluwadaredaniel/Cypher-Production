import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/system_provider.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<SystemProvider>().activity;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Activity', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Real-time log of remote commands and connections.', style: TextStyle(color: CypherColors.secondaryText)),
          const SizedBox(height: 40),
          if (activity.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No activity recorded yet.', style: TextStyle(color: CypherColors.tertiaryText)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: activity.length,
                itemBuilder: (context, index) {
                  final log = activity[index];
                  return _buildActivityItem(log);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CypherColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CypherColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(log['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(log['category']),
              size: 16,
              color: _getCategoryColor(log['category']),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(log['desc'], style: const TextStyle(color: CypherColors.secondaryText, fontSize: 13)),
              ],
            ),
          ),
          Text(
            log['time'],
            style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Connections': return CypherColors.success;
      case 'Commands': return CypherColors.info;
      case 'Security': return CypherColors.error;
      case 'Transfers': return CypherColors.warning;
      default: return CypherColors.primary;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Connections': return Icons.link_rounded;
      case 'Commands': return Icons.terminal_rounded;
      case 'Security': return Icons.security_rounded;
      case 'Transfers': return Icons.sync_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
