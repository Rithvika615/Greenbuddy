
import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../models/watering_log.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Plant> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlants();
  }

  Future<void> loadPlants() async {
    final savedPlants = await StorageService.loadPlants();

    if (!mounted) return;

    setState(() {
      plants = savedPlants;
      isLoading = false;
    });
  }

  Future<void> markWatered(Plant plant) async {
    final now = DateTime.now();

    final updatedPlants = plants.map((item) {
      if (item.id == plant.id) {
        return item.copyWith(lastWatered: now);
      }
      return item;
    }).toList();

    final logs = await StorageService.loadLogs();

    logs.add(
      WateringLog(
        id: now.microsecondsSinceEpoch.toString(),
        plantId: plant.id,
        plantName: plant.name,
        wateredOn: now,
      ),
    );

    await StorageService.savePlants(updatedPlants);
    await StorageService.saveLogs(logs);

    await loadPlants();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plant.name} watered successfully! 💧'),
      ),
    );
  }

  List<Plant> get overduePlants =>
      plants.where((p) => p.daysUntilWatering < 0).toList();

  List<Plant> get todayPlants =>
      plants.where((p) => p.daysUntilWatering == 0).toList();

  List<Plant> get upcomingPlants =>
      plants.where((p) => p.daysUntilWatering > 0).toList();

  Widget sectionTitle(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.lightGreen,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget plantReminderCard(Plant plant, String message, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.lightGreen,
          child: Icon(Icons.local_florist, color: color),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message),
        trailing: IconButton(
          tooltip: 'Mark watered',
          onPressed: () => markWatered(plant),
          icon: const Icon(
            Icons.water_drop,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadPlants,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Plant Care Reminders 🌿',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            sectionTitle(
              'Overdue',
              overduePlants.length,
              Icons.warning_amber,
            ),
            if (overduePlants.isEmpty)
              const Text('No overdue watering tasks.')
            else
              ...overduePlants.map(
                (p) => plantReminderCard(
                  p,
                  '${p.daysUntilWatering.abs()} days overdue',
                  AppColors.red,
                ),
              ),

            sectionTitle(
              'Due Today',
              todayPlants.length,
              Icons.today,
            ),
            if (todayPlants.isEmpty)
              const Text('No plants need watering today.')
            else
              ...todayPlants.map(
                (p) => plantReminderCard(
                  p,
                  'Watering is due today',
                  AppColors.orange,
                ),
              ),

            sectionTitle(
              'Upcoming',
              upcomingPlants.length,
              Icons.calendar_month,
            ),
            if (upcomingPlants.isEmpty)
              const Text('No upcoming watering tasks.')
            else
              ...upcomingPlants.map(
                (p) => plantReminderCard(
                  p,
                  'Water in ${p.daysUntilWatering} days',
                  AppColors.primary,
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
