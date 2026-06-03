import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/system_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final system = context.watch<SystemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Controls'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('POWER', style: _sectionStyle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildControlBtn(context, 'Lock', Icons.lock_outline, () => system.sendPowerCommand('lock'))),
                const SizedBox(width: 16),
                Expanded(child: _buildControlBtn(context, 'Sleep', Icons.nights_stay_outlined, () => system.sendPowerCommand('sleep'))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildControlBtn(context, 'Restart', Icons.refresh, () => system.sendPowerCommand('restart'))),
                const SizedBox(width: 16),
                Expanded(child: _buildControlBtn(context, 'Shutdown', Icons.power_settings_new, () => _confirmShutdown(context))),
              ],
            ),
            const SizedBox(height: 32),
            const Text('MEDIA', style: _sectionStyle),
            const SizedBox(height: 16),
            CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.skip_previous), onPressed: () => system.sendMediaCommand('prev')),
                  IconButton(icon: const Icon(Icons.play_arrow, size: 32), onPressed: () => system.sendMediaCommand('play')),
                  IconButton(icon: const Icon(Icons.skip_next), onPressed: () => system.sendMediaCommand('next')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('KEYBOARD', style: _sectionStyle),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'Type something...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: CypherColors.primary),
                  onPressed: () {
                    system.typeText(_typeController.text);
                    _typeController.clear();
                  },
                ),
              ),
              onSubmitted: (val) {
                system.typeText(val);
                _typeController.clear();
              },
            ),
            const SizedBox(height: 32),
            const Text('SCREEN RECORDING', style: _sectionStyle),
            const SizedBox(height: 16),
            CustomCard(
              child: Row(
                children: [
                  const Expanded(child: Text('PC Screen Record')),
                  IconButton(
                    icon: const Icon(Icons.fiber_manual_record, color: CypherColors.error),
                    onPressed: () => context.read<ApiService>().post('/recording/start'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => context.read<ApiService>().post('/recording/stop'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: CypherColors.secondaryText),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmShutdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CypherColors.secondaryBackground,
        title: const Text('Confirm Shutdown?'),
        content: const Text('Are you sure you want to shutdown your PC?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<SystemProvider>().sendPowerCommand('shutdown');
              Navigator.pop(context);
            },
            child: const Text('Shutdown', style: TextStyle(color: CypherColors.error)),
          ),
        ],
      ),
    );
  }

  static const _sectionStyle = TextStyle(
    color: CypherColors.tertiaryText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}
