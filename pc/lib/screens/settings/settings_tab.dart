import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _nameController = TextEditingController();
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final res = await context.read<ApiService>().get('/settings');
      setState(() {
        _settings = res;
        _nameController.text = res['device_name'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final newSettings = Map<String, dynamic>.from(_settings);
      newSettings['device_name'] = _nameController.text;

      await context.read<ApiService>().post('/settings', body: newSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully'), backgroundColor: CypherColors.success),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Configure your PC visibility and security.', style: TextStyle(color: CypherColors.secondaryText)),
          const SizedBox(height: 40),
          _buildSection('DEVICE IDENTIFICATION'),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'PC Display Name',
              hintText: 'e.g. Work Station',
            ),
          ),
          const SizedBox(height: 32),
          _buildSection('NOTIFICATIONS'),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Show Desktop Notifications',
            'Display alerts when devices connect or files are received.',
            _settings['notifications_enabled'] ?? true,
            (val) => setState(() => _settings['notifications_enabled'] = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Auto Clipboard Sync',
            'Instantly sync clipboard between PC and Phone.',
            _settings['auto_clipboard_sync'] ?? false,
            (val) => setState(() => _settings['auto_clipboard_sync'] = val),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: CypherColors.tertiaryText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CypherColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CypherColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: CypherColors.primary,
          ),
        ],
      ),
    );
  }
}
