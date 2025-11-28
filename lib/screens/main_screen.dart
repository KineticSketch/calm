import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'home_screen.dart';
import 'overview_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    OverviewScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: isDark
            ? const Color(0xFF2D2D2D)
            : Theme.of(context).primaryColor,
        color: isDark ? Colors.grey[600] : Colors.white70,
        activeColor: isDark ? Theme.of(context).primaryColor : Colors.white,
        items: const [
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.calendar_month),
          TabItem(icon: Icons.settings),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
