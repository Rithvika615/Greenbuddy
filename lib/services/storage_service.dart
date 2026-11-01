
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';
import '../models/growth_log.dart';
import '../models/watering_log.dart';

class StorageService {
  static const String plantKey = 'greenbuddy_plants';
  static const String logKey = 'greenbuddy_watering_logs';
  static const String growthKey = 'greenbuddy_growth_logs';

  static Future<void> savePlants(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();

    final data = plants.map((p) => p.toJson()).toList();

    await prefs.setString(plantKey, jsonEncode(data));
  }

  static Future<List<Plant>> loadPlants() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(plantKey);

    if (data == null) return [];

    final List decoded = jsonDecode(data);

    return decoded
        .map((item) => Plant.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }
  static Future<void> saveGrowthLogs(List<GrowthLog> logs) async {
  final prefs = await SharedPreferences.getInstance();
  final data = logs.map((log) => log.toJson()).toList();
  await prefs.setString(growthKey, jsonEncode(data));
}

static Future<List<GrowthLog>> loadGrowthLogs() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(growthKey);

  if (data == null) return [];

  final List decoded = jsonDecode(data);

  return decoded
      .map((item) => GrowthLog.fromJson(
            Map<String, dynamic>.from(item),
          ))
      .toList();
}
  static Future<void> saveLogs(List<WateringLog> logs) async {
    final prefs = await SharedPreferences.getInstance();

    final data = logs.map((log) => log.toJson()).toList();

    await prefs.setString(logKey, jsonEncode(data));
  }

  static Future<List<WateringLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(logKey);

    if (data == null) return [];

    final List decoded = jsonDecode(data);

    return decoded
        .map((item) => WateringLog.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(plantKey);
    await prefs.remove(logKey);
  }
}
