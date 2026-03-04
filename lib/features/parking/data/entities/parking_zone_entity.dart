class ParkingZoneEntity {
  final String id;
  final String name;
  final int totalSpot;
  final String type;

  const ParkingZoneEntity({
    required this.id,
    required this.name,
    required this.totalSpot,
    required this.type,
  });

  factory ParkingZoneEntity.fromJson(Map<String, dynamic> json) {
    return ParkingZoneEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      totalSpot: json['totalSpot'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalSpot': totalSpot,
        'type': type,
      };
}
