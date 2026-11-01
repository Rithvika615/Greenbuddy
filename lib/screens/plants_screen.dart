
import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../models/watering_log.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<Plant> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlants();
  }

  // Load saved plants
  Future<void> loadPlants() async {
    final savedPlants = await StorageService.loadPlants();

    if (!mounted) return;

    setState(() {
      plants = savedPlants;
      isLoading = false;
    });
  }

  // Save plants
  Future<void> savePlants() async {
    await StorageService.savePlants(plants);
  }

  // Add a new plant
  Future<void> addPlant() async {
    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final intervalController = TextEditingController(text: '7');
    final notesController = TextEditingController();

    final newPlant = await showDialog<Plant>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Plant 🌱'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plant Name',
                    prefixIcon: Icon(Icons.local_florist),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Plant Type / Species',
                    prefixIcon: Icon(Icons.eco),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: intervalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Watering Interval (days)',
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final interval =
                    int.tryParse(intervalController.text.trim());

                if (name.isEmpty || interval == null || interval <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a plant name and valid watering interval.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  Plant(
                    id: DateTime.now()
                        .microsecondsSinceEpoch
                        .toString(),
                    name: name,
                    species: speciesController.text.trim(),
                    wateringInterval: interval,
                    lastWatered: DateTime.now(),
                    notes: notesController.text.trim(),
                  ),
                );
              },
              child: const Text('Save Plant'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    speciesController.dispose();
    intervalController.dispose();
    notesController.dispose();

    if (newPlant != null) {
      setState(() {
        plants.add(newPlant);
      });

      await savePlants();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plant added successfully! 🌱'),
        ),
      );
    }
  }

  // Mark plant as watered and save its history
  Future<void> markWatered(Plant plant) async {
    final now = DateTime.now();

    final updatedPlants = plants.map((item) {
      if (item.id == plant.id) {
        return item.copyWith(
          lastWatered: now,
        );
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

  // Delete plant
  Future<void> deletePlant(Plant plant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Plant?'),
          content: Text(
            'Are you sure you want to delete ${plant.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      plants.removeWhere((item) => item.id == plant.id);
    });

    await savePlants();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plant deleted successfully.'),
      ),
    );
  }

  // Plant card
  Widget plantCard(Plant plant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.local_florist,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Text(
                        plant.species.isEmpty
                            ? 'Plant'
                            : plant.species,
                        style: const TextStyle(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => deletePlant(plant),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Water every ${plant.wateringInterval} days',
            ),
            const SizedBox(height: 5),
            Text(
              plant.isDue
                  ? 'Watering is due!'
                  : 'Next watering in ${plant.daysUntilWatering} days',
              style: TextStyle(
                color: plant.isDue
                    ? AppColors.red
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (plant.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${plant.notes}'),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => markWatered(plant),
                icon: const Icon(Icons.water_drop),
                label: const Text('Mark Watered'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addPlant,
        icon: const Icon(Icons.add),
        label: const Text('Add Plant'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPlants,
              child: plants.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.local_florist,
                          size: 70,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No plants added yet!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Tap Add Plant to get started.',
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        90,
                      ),
                      children: [
                        Text(
                          'My Plants (${plants.length})',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...plants.map(plantCard),
                      ],
                    ),
            ),
    );
  }
}
