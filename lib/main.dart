
import 'package:flutter/material.dart';

import 'utils/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/care_tips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/growth_tracker_screen.dart';
import 'screens/watering_calendar_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GreenBuddy());
}

class GreenBuddy extends StatelessWidget {
  const GreenBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenBuddy',
      theme: AppTheme.lightTheme,

      // Navigation routes
      routes: {
        '/growth': (context) => const GrowthTrackerScreen(),
        '/calendar': (context) => const WateringCalendarScreen(),
      },

      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    PlantsScreen(),
    RemindersScreen(),
    CareTipsScreen(),
    ProfileScreen(),
  ];

  final List<String> titles = [
    'GreenBuddy',
    'My Plants',
    'Reminders',
    'Care Tips',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${titles[selectedIndex]} 🌱',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Display selected bottom navigation screen
      body: screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
