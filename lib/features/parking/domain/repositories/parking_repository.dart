import '../../domain/models/parking_lot.dart';

abstract class ParkingRepository {
  Future<List<ParkingLot>> getParkingLots();
  // Future<List<ParkingLot>> refreshStatus();
  // Future<ParkingLotDetail?> getParkingLotDetail(String id);  // nullable
}
