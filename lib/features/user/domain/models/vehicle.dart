enum VehicleType { sedan, suv, van, motorcycle, other }

class Vehicle {
  final String id;
  final String plateNumber;
  final String? manufacturer;
  final String? model;
  final String? color;
  final String? nickName;
  final VehicleType type;

  const Vehicle({
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
    'type': type.name,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'],
    plateNumber: json['plateNumber'],
    manufacturer: json['manufacturer'],
    model: json['model'],
    color: json['color'],
    nickName: json['nickName'],
    type: VehicleType.values.byName(json['type']),
  );

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? manufacturer,
    String? model,
    String? color,
    String? nickName,
    VehicleType? type,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      color: color ?? this.color,
      nickName: nickName ?? this.nickName,
      type: type ?? this.type,
    );
  }
}
