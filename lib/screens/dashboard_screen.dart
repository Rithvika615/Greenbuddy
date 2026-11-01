
import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Plant> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final savedPlants = await StorageService.loadPlants();

    if (!mounted) return;

    setState(() {
      plants = savedPlants;
      isLoading = false;
    });
  }

  int get totalPlants => plants.length;

  int get waterToday =>
      plants.where((p) => p.daysUntilWatering <= 0).length;

  int get healthyPlants =>
      plants.where((p) => p.healthStatus == 'Healthy').length;

  int get totalReminders =>
      plants.where((p) => p.daysUntilWatering <= 3).length;

  Future<void> openTool(String route) async {
    await Navigator.pushNamed(context, route);

    if (mounted) {
      loadDashboard();
    }
  }

  Widget gardenToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.darkGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Plant Lover! 🌿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Give your plants the care they deserve.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Garden overview
            const Text(
              'Your Garden Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: OverviewCard(
                      title: 'My Plants',
                      value: '$totalPlants',
                      icon: Icons.local_florist,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OverviewCard(
                      title: 'Water Today',
                      value: '$waterToday',
                      icon: Icons.water_drop,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OverviewCard(
                      title: 'Healthy',
                      value: '$healthyPlants',
                      icon: Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OverviewCard(
                      title: 'Reminders',
                      value: '$totalReminders',
                      icon: Icons.notifications,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Daily plant care
            const Text(
              'Daily Plant Care 🌱',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                  size: 32,
                ),
                title: Text('Water your plants'),
                subtitle: Text(
                  'Check the soil before watering.',
                ),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 32,
                ),
                title: Text('Provide sunlight'),
                subtitle: Text(
                  'Keep plants in suitable lighting.',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Garden tools
            const Text(
              'Garden Tools 🌿',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            gardenToolCard(
              title: 'Growth Tracker',
              subtitle: 'Track plant height, leaves and growth photos.',
              icon: Icons.trending_up,
              onTap: () => openTool('/growth'),
            ),

            gardenToolCard(
              title: 'Watering Calendar',
              subtitle: 'View watering schedules and watering history.',
              icon: Icons.calendar_month,
              onTap: () => openTool('/calendar'),
            ),

            // Recently added plants
            if (plants.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Text(
                'Recently Added Plants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...plants.reversed.take(3).map(
                (plant) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.eco,
                      color: AppColors.primary,
                    ),
                    title: Text(plant.name),
                    subtitle: Text(plant.species),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
