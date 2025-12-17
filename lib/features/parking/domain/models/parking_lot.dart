class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int totalSpots;
  final int availableSpots;
  final int? fee;
  final double? distance;

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.totalSpots,
    required this.availableSpots,
    this.fee,
    this.distance,
  });

  // 거리 정보 추가한 새 객체 반환
  ParkingLot copyWith({double? distance}) {
    return ParkingLot(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      totalSpots: totalSpots,
      availableSpots: availableSpots,
      fee: fee,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'ParkingLot{name: $name}';
  }
}
