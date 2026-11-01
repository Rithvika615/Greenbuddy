
class Plant {
  final String id;
  final String name;
  final String species;
  final int wateringInterval;
  final DateTime lastWatered;
  final String notes;
  final String imagePath;
  final String healthStatus;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.wateringInterval,
    required this.lastWatered,
    this.notes = '',
    this.imagePath = '',
    this.healthStatus = 'Healthy',
  });

  DateTime get nextWateringDate =>
      lastWatered.add(Duration(days: wateringInterval));

  bool get isDue =>
      !nextWateringDate.isAfter(DateTime.now());

  int get daysUntilWatering {
    final today = DateTime.now();
    final due = DateTime(
      nextWateringDate.year,
      nextWateringDate.month,
      nextWateringDate.day,
    );
    final current = DateTime(today.year, today.month, today.day);

    return due.difference(current).inDays;
  }

  Plant copyWith({
    String? name,
    String? species,
    int? wateringInterval,
    DateTime? lastWatered,
    String? notes,
    String? imagePath,
    String? healthStatus,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      wateringInterval: wateringInterval ?? this.wateringInterval,
      lastWatered: lastWatered ?? this.lastWatered,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      healthStatus: healthStatus ?? this.healthStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'wateringInterval': wateringInterval,
      'lastWatered': lastWatered.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
      'healthStatus': healthStatus,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      species: json['species'] ?? '',
      wateringInterval: json['wateringInterval'],
      lastWatered: DateTime.parse(json['lastWatered']),
      notes: json['notes'] ?? '',
      imagePath: json['imagePath'] ?? '',
      healthStatus: json['healthStatus'] ?? 'Healthy',
    );
  }
}
