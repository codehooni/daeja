class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalSpaces; // whol_npls
  final int availableSpaces; // 잔여주차면수 = infoState 합산 값

  ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalSpaces,
    required this.availableSpaces,
  });

  factory ParkingLot.fromJson(
    Map<String, dynamic> info,
    Map<String, dynamic>? state,
  ) {
    final gnrl = state?['gnrl'] ?? 0;
    final lgvh = state?['lgvh'] ?? 0;
    final hvvh = state?['hvvh'] ?? 0;
    final emvh = state?['emvh'] ?? 0;
    final hndc = state?['hndc'] ?? 0;
    final wmon = state?['wmon'] ?? 0;
    final etc = state?['etc'] ?? 0;

    final available = gnrl + lgvh + hvvh + emvh + hndc + wmon + etc;

    return ParkingLot(
      id: info['id'],
      name: info['name'],
      address: info['addr'],
      latitude: info['y_crdn'],
      longitude: info['x_crdn'],
      totalSpaces: info['whol_npls'],
      availableSpaces: available,
    );
  }
}
