
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/watering_log.dart';
import '../services/storage_service.dart';
import '../widgets/calendar_widget.dart';
import '../utils/app_colors.dart';

class WateringCalendarScreen extends StatefulWidget {
  const WateringCalendarScreen({super.key});

  @override
  State<WateringCalendarScreen> createState() =>
      _WateringCalendarScreenState();
}

class _WateringCalendarScreenState
    extends State<WateringCalendarScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<Plant> plants = [];
  List<WateringLog> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final savedPlants = await StorageService.loadPlants();
    final savedLogs = await StorageService.loadLogs();

    if (!mounted) return;

    setState(() {
      plants = savedPlants;
      logs = savedLogs;
      isLoading = false;
    });
  }

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> get wateringDates {
    final dates = <DateTime>[];

    for (final plant in plants) {
      DateTime nextDate = dateOnly(plant.nextWateringDate);

      while (nextDate.year < focusedDay.year ||
          (nextDate.year == focusedDay.year &&
              nextDate.month <= focusedDay.month)) {
        if (nextDate.year == focusedDay.year &&
            nextDate.month == focusedDay.month) {
          dates.add(nextDate);
        }

        nextDate = nextDate.add(
          Duration(days: plant.wateringInterval),
        );
      }
    }

    for (final log in logs) {
      dates.add(dateOnly(log.wateredOn));
    }

    return dates;
  }

  List<Plant> get selectedPlants {
    return plants.where((plant) {
      final nextDate = dateOnly(plant.nextWateringDate);
      return nextDate == dateOnly(selectedDay);
    }).toList();
  }

  List<WateringLog> get selectedLogs {
    return logs.where((log) {
      return dateOnly(log.wateredOn) == dateOnly(selectedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watering Calendar 🌿'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CalendarWidget(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              wateringDates: wateringDates,
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Schedule for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedPlants.isEmpty && selectedLogs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No watering activities for this date.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ...selectedPlants.map((plant) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(
                        Icons.local_florist,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(plant.name),
                    subtitle: const Text('Scheduled watering'),
                    trailing: const Icon(
                      Icons.water_drop,
                      color: AppColors.blue,
                    ),
                  ),
                )),
            ...selectedLogs.map((log) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    ),
                    title: Text(log.plantName),
                    subtitle: const Text('Watered successfully'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
