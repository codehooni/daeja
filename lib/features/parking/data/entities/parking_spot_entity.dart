class ParkingSpotEntity {
  final String id;
  final String name;
  final String status;
  final String zoneId;
  final String? currentReservationId;
  final String? currentVehicleId;

  const ParkingSpotEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.zoneId,
    this.currentReservationId,
    this.currentVehicleId,
  });

  factory ParkingSpotEntity.fromJson(Map<String, dynamic> json) {
    return ParkingSpotEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      zoneId: json['zone_id'] as String,
      currentReservationId: json['current_reservation_id'] as String?,
      currentVehicleId: json['current_vehicle_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'zone_id': zoneId,
        'current_reservation_id': currentReservationId,
        'current_vehicle_id': currentVehicleId,
      };
}
