import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/system_provider.dart';
import '../../widgets/custom_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _batteryAlerts = true;
  double _batteryThreshold = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DEVICE', style: _sectionLabelStyle),
            const SizedBox(height: 16),
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: CypherColors.primary),
                title: const Text('App Version', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('1.0.0+1 (Production)'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('NOTIFICATIONS', style: _sectionLabelStyle),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchRow(
                    'Push Notifications',
                    'Alert when PC state changes',
                    _notifications,
                    (v) => setState(() => _notifications = v),
                  ),
                  const Divider(color: CypherColors.defaultBorder, height: 24),
                  _buildSwitchRow(
                    'Battery Alerts',
                    'Notify when PC battery is low',
                    _batteryAlerts,
                    (v) => setState(() => _batteryAlerts = v),
                  ),
                  if (_batteryAlerts) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Threshold', style: TextStyle(fontSize: 13, color: CypherColors.secondaryText)),
                        Expanded(
                          child: Slider(
                            value: _batteryThreshold,
                            min: 5,
                            max: 50,
                            divisions: 9,
                            activeColor: CypherColors.primary,
                            onChanged: (v) => setState(() => _batteryThreshold = v),
                          ),
                        ),
                        Text('${_batteryThreshold.round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('CONNECTION', style: _sectionLabelStyle),
            const SizedBox(height: 16),
            CustomCard(
              onTap: () => _showUnpairDialog(context),
              child: Row(
                children: [
                  const Icon(Icons.link_off_rounded, color: CypherColors.error),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unpair Device', style: TextStyle(fontWeight: FontWeight.w600, color: CypherColors.error)),
                        Text('Disconnect from current PC', style: TextStyle(fontSize: 12, color: CypherColors.tertiaryText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Cypher Local v1.0\nMade with ❤️ for local-first users',
                textAlign: TextAlign.center,
                style: TextStyle(color: CypherColors.tertiaryText, fontSize: 11, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, String desc, bool val, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(desc, style: const TextStyle(fontSize: 12, color: CypherColors.secondaryText)),
            ],
          ),
        ),
        Switch(
          value: val,
          onChanged: onChanged,
          activeColor: CypherColors.primary,
        ),
      ],
    );
  }

  void _showUnpairDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CypherColors.secondaryBackground,
        title: const Text('Unpair Device?'),
        content: const Text('This will remove the connection and auth token. You will need to pair again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().unpair();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Unpair', style: TextStyle(color: CypherColors.error)),
          ),
        ],
      ),
    );
  }

  static const _sectionLabelStyle = TextStyle(
    color: CypherColors.tertiaryText,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );
}
