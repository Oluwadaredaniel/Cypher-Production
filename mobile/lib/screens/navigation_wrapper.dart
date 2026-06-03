import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'home/home_screen.dart';
import 'files/file_browser_screen.dart';
import 'controls/controls_screen.dart';
import 'activity/activity_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FileBrowserScreen(),
    const ControlsScreen(),
    const ActivityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: CypherColors.defaultBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: CypherColors.secondaryBackground,
          selectedItemColor: CypherColors.primary,
          unselectedItemColor: CypherColors.secondaryText,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_rounded),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mouse_rounded),
              label: 'Controls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Activity',
            ),
          ],
        ),
      ),
    );
  }
}
