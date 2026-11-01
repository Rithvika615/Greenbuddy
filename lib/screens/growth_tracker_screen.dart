
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import '../models/growth_log.dart';
import '../services/storage_service.dart';
import '../widgets/growth_chart.dart';
import '../utils/app_colors.dart';

class GrowthTrackerScreen extends StatefulWidget {
  const GrowthTrackerScreen({super.key});

  @override
  State<GrowthTrackerScreen> createState() =>
      _GrowthTrackerScreenState();
}

class _GrowthTrackerScreenState extends State<GrowthTrackerScreen> {
  List<Plant> plants = [];
  List<GrowthLog> logs = [];

  Plant? selectedPlant;
  bool isLoading = true;

  final ImagePicker picker = ImagePicker();
  String? selectedImageData;

  final heightController = TextEditingController();
  final leavesController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    heightController.dispose();
    leavesController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final savedPlants = await StorageService.loadPlants();
    final savedLogs = await StorageService.loadGrowthLogs();

    if (!mounted) return;

    setState(() {
      plants = savedPlants;
      logs = savedLogs;

      if (selectedPlant == null && plants.isNotEmpty) {
        selectedPlant = plants.first;
      } else if (selectedPlant != null) {
        selectedPlant = plants.cast<Plant?>().firstWhere(
          (plant) => plant?.id == selectedPlant!.id,
          orElse: () => plants.isEmpty ? null : plants.first,
        );
      }

      isLoading = false;
    });
  }

  List<GrowthLog> get selectedLogs {
    if (selectedPlant == null) return [];

    return logs
        .where((log) => log.plantId == selectedPlant!.id)
        .toList()
      ..sort((a, b) => a.recordedOn.compareTo(b.recordedOn));
  }

  // Select a plant photo from Gallery
  Future<void> pickPlantPhoto() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageData = base64Encode(bytes);
      });
    } catch (e) {
      showMessage('Unable to select photo. Please try again.');
    }
  }

  void removeSelectedPhoto() {
    setState(() {
      selectedImageData = null;
    });
  }

  Future<void> saveGrowthRecord() async {
    if (selectedPlant == null) return;

    final heightText = heightController.text.trim();
    final leavesText = leavesController.text.trim();

    final height = heightText.isEmpty
        ? null
        : double.tryParse(heightText);

    final leaves = leavesText.isEmpty
        ? null
        : int.tryParse(leavesText);

    if (heightText.isNotEmpty &&
        (height == null || height <= 0)) {
      showMessage('Enter a valid plant height.');
      return;
    }

    if (leavesText.isNotEmpty &&
        (leaves == null || leaves < 0)) {
      showMessage('Enter a valid leaf count.');
      return;
    }

    if (height == null &&
        leaves == null &&
        notesController.text.trim().isEmpty &&
        selectedImageData == null) {
      showMessage(
        'Add a measurement, observation, or photo.',
      );
      return;
    }

    final record = GrowthLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      plantId: selectedPlant!.id,
      plantName: selectedPlant!.name,
      recordedOn: DateTime.now(),
      heightCm: height,
      leafCount: leaves,
      notes: notesController.text.trim(),
      imageData: selectedImageData ?? '',
    );

    final updatedLogs = [...logs, record];

    try {
      await StorageService.saveGrowthLogs(updatedLogs);

      if (!mounted) return;

      setState(() {
        logs = updatedLogs;
        heightController.clear();
        leavesController.clear();
        notesController.clear();
        selectedImageData = null;
      });

      showMessage('Growth record saved successfully! 🌱');
    } catch (e) {
      showMessage('Could not save record. Please try again.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildMeasurementCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plant Growth Photo',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 10),

        if (selectedImageData != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(selectedImageData!),
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: removeSelectedPhoto,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Photo'),
            ),
          ),
        ],

        OutlinedButton.icon(
          onPressed: pickPlantPhoto,
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose from Gallery'),
        ),
      ],
    );
  }

  Widget buildHistoryPhoto(String imageData) {
    if (imageData.isEmpty) {
      return const CircleAvatar(
        backgroundColor: AppColors.lightGreen,
        child: Icon(
          Icons.trending_up,
          color: AppColors.primary,
        ),
      );
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          base64Decode(imageData),
          width: 65,
          height: 65,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      return const CircleAvatar(
        backgroundColor: AppColors.lightGreen,
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (plants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Growth Tracker 🌱'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Add a plant in My Plants before tracking its growth.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final plantLogs = selectedLogs;

    final heightLogs = plantLogs
        .where((log) => log.heightCm != null)
        .toList();

    final leafLogs = plantLogs
        .where((log) => log.leafCount != null)
        .toList();

    final latestHeight =
        heightLogs.isEmpty ? null : heightLogs.last.heightCm;

    final latestLeaves =
        leafLogs.isEmpty ? null : leafLogs.last.leafCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracker 🌱'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Select Your Plant',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedPlant?.id,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.local_florist),
                labelText: 'Choose Plant',
              ),
              items: plants.map((plant) {
                return DropdownMenuItem(
                  value: plant.id,
                  child: Text(plant.name),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;

                setState(() {
                  selectedPlant = plants.firstWhere(
                    (plant) => plant.id == id,
                  );
                  selectedImageData = null;
                });
              },
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                buildMeasurementCard(
                  'Height',
                  latestHeight == null
                      ? '--'
                      : '${latestHeight.toStringAsFixed(1)} cm',
                  Icons.height,
                ),
                buildMeasurementCard(
                  'Leaves',
                  latestLeaves?.toString() ?? '--',
                  Icons.eco,
                ),
                buildMeasurementCard(
                  'Records',
                  plantLogs.length.toString(),
                  Icons.history,
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Add Growth Record',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: heightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Plant Height (cm)',
                prefixIcon: Icon(Icons.height),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: leavesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Leaves',
                prefixIcon: Icon(Icons.eco),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Growth Observations',
                hintText:
                    'Describe new leaves or other changes...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 16),

            buildPhotoPicker(),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveGrowthRecord,
                icon: const Icon(Icons.save),
                label: const Text('Save Growth Record'),
              ),
            ),

            const SizedBox(height: 24),

            GrowthChart(logs: plantLogs),

            const SizedBox(height: 20),

            const Text(
              'Growth History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),

            const SizedBox(height: 10),

            if (plantLogs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'No growth records yet. Add your first measurement!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            ...plantLogs.reversed.map((log) {
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),

                  leading: buildHistoryPhoto(log.imageData),

                  title: Text(
                    '${log.heightCm == null ? 'Height not recorded' : '${log.heightCm} cm'}'
                    ' • ${log.leafCount == null ? 'Leaves not recorded' : '${log.leafCount} leaves'}',
                  ),

                  subtitle: Text(
                    '${log.recordedOn.day}/${log.recordedOn.month}/${log.recordedOn.year}'
                    '${log.notes.isEmpty ? '' : '\n${log.notes}'}',
                  ),

                  isThreeLine: log.notes.isNotEmpty,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
