import '../../domain/models/parking_lot.dart';

class ParkingSearchService {
  List<ParkingLot> search(List<ParkingLot> lots, String query) {
    if (query.isEmpty) return lots;

    final lowerQuery = query.toLowerCase();
    return lots.where((lot) {
      return lot.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<ParkingLot> filterAvailable(List<ParkingLot> lots) {
    return lots.where((lot) => lot.availableSpots > 0).toList();
  }
}
