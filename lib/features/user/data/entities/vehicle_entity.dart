class VehicleEntity {
  final String id;
  final String plateNumber;
  final String? manufacturer;
  final String? model;
  final String? color;
  final String? nickName;
  final String type;

  const VehicleEntity({
    required this.id,
    required this.plateNumber,
    this.manufacturer,
    this.model,
    this.color,
    this.nickName,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'plateNumber': plateNumber,
        'manufacturer': manufacturer,
        'model': model,
        'color': color,
        'nickName': nickName,
        'type': type,
      };

  factory VehicleEntity.fromJson(Map<String, dynamic> json) => VehicleEntity(
        id: json['id'] as String,
        plateNumber: json['plateNumber'] as String,
        manufacturer: json['manufacturer'] as String?,
        model: json['model'] as String?,
        color: json['color'] as String?,
        nickName: json['nickName'] as String?,
        type: json['type'] as String,
      );
}
