
class GrowthLog {
  final String id;
  final String plantId;
  final String plantName;
  final DateTime recordedOn;
  final double? heightCm;
  final int? leafCount;
  final String notes;
  final String imageData;

  GrowthLog({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.recordedOn,
    this.heightCm,
    this.leafCount,
    this.notes = '',
    this.imageData = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'recordedOn': recordedOn.toIso8601String(),
      'heightCm': heightCm,
      'leafCount': leafCount,
      'notes': notes,
      'imageData': imageData,
    };
  }

  factory GrowthLog.fromJson(Map<String, dynamic> json) {
    return GrowthLog(
      id: json['id'],
      plantId: json['plantId'],
      plantName: json['plantName'],
      recordedOn: DateTime.parse(json['recordedOn']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      leafCount: json['leafCount'] as int?,
      notes: json['notes'] ?? '',
      imageData: json['imageData'] ?? '',
    );
  }
}
