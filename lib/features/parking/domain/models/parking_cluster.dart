import '../../domain/models/parking_lot.dart';

class ParkingCluster {
  final String id;
  final double lat;
  final double lng;
  final List<ParkingLot> parkingLots;
  final int totalAvailable;

  const ParkingCluster({
    required this.id,
    required this.lat,
    required this.lng,
    required this.parkingLots,
    required this.totalAvailable,
  });

  int get count => parkingLots.length;
}
