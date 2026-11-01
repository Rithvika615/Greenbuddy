
class WateringLog {
  final String id;
  final String plantId;
  final String plantName;
  final DateTime wateredOn;

  WateringLog({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.wateredOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'wateredOn': wateredOn.toIso8601String(),
    };
  }

  factory WateringLog.fromJson(Map<String, dynamic> json) {
    return WateringLog(
      id: json['id'],
      plantId: json['plantId'],
      plantName: json['plantName'],
      wateredOn: DateTime.parse(json['wateredOn']),
    );
  }
}
