import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/system_provider.dart';
import '../../widgets/usage_graph.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final system = context.watch<SystemProvider>();
    final stats = system.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: Text('Welcome Back', style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 8),
          FadeInDown(delay: const Duration(milliseconds: 100), child: const Text('System Overview', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700))),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: FadeInLeft(child: _buildPairingCard(context, system.pairingCode))),
              const SizedBox(width: 24),
              Expanded(
                child: FadeInUp(
                  child: _buildResourceCard(
                    'CPU Usage',
                    '${stats?['cpu_percent'] ?? 0}%',
                    Icons.memory_rounded,
                    CypherColors.info,
                    system.cpuHistory,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: FadeInRight(
                  child: _buildResourceCard(
                    'RAM Usage',
                    '${stats?['ram_percent'] ?? 0}%',
                    Icons.speed_rounded,
                    CypherColors.warning,
                    system.ramHistory,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text('PAIRED DEVICES', style: _sectionLabelStyle),
          const SizedBox(height: 16),
          if (system.pairedDevices.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No devices paired yet.'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: system.pairedDevices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildDeviceItem(context, system.pairedDevices[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildPairingCard(BuildContext context, String code) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: CypherColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR PAIRING CODE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: 10)),
              IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28), onPressed: () => context.read<SystemProvider>().rotatePairingCode()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String value, IconData icon, Color color, List<double> history) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CypherColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CypherColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: CypherColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(height: 40, child: UsageGraph(values: history, color: color)),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, Map<String, dynamic> device) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CypherColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CypherColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.smartphone_rounded, color: CypherColors.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device['device_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Paired on ${device['paired_at']}', style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.read<SystemProvider>().unpairDevice(device['device_id']),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: CypherColors.error)),
            child: const Text('Unpair', style: TextStyle(color: CypherColors.error, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static const _sectionLabelStyle = TextStyle(color: CypherColors.tertiaryText, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5);
}
