import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/system_provider.dart';
import '../home/home_tab.dart';
import '../files/files_tab.dart';
import '../controls/controls_tab.dart';
import '../activity/activity_tab.dart';
import '../settings/settings_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const FilesTab(),
    const ControlsTab(),
    const ActivityTab(),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              color: CypherColors.primaryBackground,
              child: _tabs[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: CypherColors.secondaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'CYPHER',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                    color: CypherColors.primary,
                  ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: CypherColors.tertiaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSidebarItem(0, 'Home', Icons.home_filled),
          _buildSidebarItem(1, 'Files', Icons.folder_rounded),
          _buildSidebarItem(2, 'Controls', Icons.mouse_rounded),
          _buildSidebarItem(3, 'Activity', Icons.history_rounded),
          _buildSidebarItem(4, 'Settings', Icons.settings_rounded),
          const Spacer(),
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          icon,
          color: isSelected ? CypherColors.primary : CypherColors.secondaryText,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? CypherColors.primaryText : CypherColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
        tileColor: isSelected ? CypherColors.tertiaryBackground : Colors.transparent,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isRunning = context.watch<SystemProvider>().isServerRunning;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isRunning ? CypherColors.success : CypherColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                if (isRunning)
                  BoxShadow(color: CypherColors.success.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isRunning ? 'Server Online' : 'Server Offline',
            style: TextStyle(
              color: isRunning ? CypherColors.primaryText : CypherColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
