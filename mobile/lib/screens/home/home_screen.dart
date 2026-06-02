import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/system_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/usage_graph.dart';
import '../files/file_browser_screen.dart';
import '../controls/controls_screen.dart';
import '../clipboard/clipboard_screen.dart';
import '../activity/activity_screen.dart';
import '../controls/app_launcher_screen.dart';
import '../controls/process_manager_screen.dart';

import 'settings_screen.dart';
import 'guest_access_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    final system = context.watch<SystemProvider>();
    final auth = context.watch<AuthProvider>();
    final stats = system.stats;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      status: system.isConnected
                          ? ConnectionStatus.connected
                          : ConnectionStatus.disconnected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: CypherColors.secondaryText),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeInLeft(
                child: CustomCard(
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connected to PC',
                              style: TextStyle(color: CypherColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              auth.deviceName ?? 'Desktop-PC',
                              style: const TextStyle(color: CypherColors.primaryText, fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats?['pc_ip'] ?? '192.168.1.10',
                              style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (stats?['battery_percent'] != null)
                        Column(
                          children: [
                            Icon(
                              stats!['battery_plugged'] ? Icons.battery_charging_full : Icons.battery_full,
                              color: (stats['battery_percent'] as int) < 20 ? CypherColors.error : CypherColors.success,
                            ),
                            Text('${stats['battery_percent']}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FadeInUp(
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CPU', style: TextStyle(color: CypherColors.secondaryText, fontSize: 12)),
                            Text('${stats?['cpu_percent'] ?? 0}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SizedBox(height: 30, child: UsageGraph(values: system.cpuHistory, color: CypherColors.info)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('RAM', style: TextStyle(color: CypherColors.secondaryText, fontSize: 12)),
                            Text('${stats?['ram_percent'] ?? 0}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SizedBox(height: 30, child: UsageGraph(values: system.ramHistory, color: CypherColors.warning)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildMenuCard(context, 'Files', Icons.folder_outlined, const FileBrowserScreen(), delay: 200),
                  _buildMenuCard(context, 'Controls', Icons.mouse_outlined, const ControlsScreen(), delay: 300),
                  _buildMenuCard(context, 'Apps', Icons.apps_rounded, const AppLauncherScreen(), delay: 400),
                  _buildMenuCard(context, 'Processes', Icons.list_alt_rounded, const ProcessManagerScreen(), delay: 500),
                ],
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Expanded(child: _buildActionTile(context, 'Clipboard', Icons.content_paste_outlined, const ClipboardScreen())),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionTile(context, 'Guest', Icons.qr_code_2_rounded, const GuestAccessScreen())),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Row(
                  children: [
                    Expanded(child: _buildActionTile(context, 'Activity', Icons.history_outlined, const ActivityScreen())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget screen, {int delay = 0}) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: CustomCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CypherColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: CypherColors.primaryText, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Widget screen) {
    return CustomCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CypherColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showUnpairDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CypherColors.secondaryBackground,
        title: const Text('Unpair Device?'),
        content: const Text('This will remove the connection to your PC.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().unpair();
              Navigator.pop(context);
            },
            child: const Text('Unpair', style: TextStyle(color: CypherColors.error)),
          ),
        ],
      ),
    );
  }
}
