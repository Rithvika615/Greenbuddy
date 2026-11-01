
import '../models/plant.dart';

class ReminderService {
  static List<Plant> getDuePlants(List<Plant> plants) {
    return plants.where((plant) => plant.isDue).toList();
  }

  static List<Plant> getUpcomingPlants(List<Plant> plants) {
    return plants
        .where((plant) =>
            !plant.isDue && plant.daysUntilWatering <= 3)
        .toList();
  }

  static List<Plant> getAllScheduledPlants(List<Plant> plants) {
    final result = List<Plant>.from(plants);

    result.sort(
      (a, b) => a.nextWateringDate.compareTo(b.nextWateringDate),
    );

    return result;
  }
}
