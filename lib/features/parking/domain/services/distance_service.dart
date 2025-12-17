import 'dart:math';

import '../../domain/models/parking_lot.dart';
import '../../../location/domain/models/user_location.dart';

class DistanceService {
  // 두 좌표 사이 거리 계산 (km)
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // 주차장 목록에 거리 정보 추가
  List<ParkingLot> addDistanceToLots(
    List<ParkingLot> lots,
    UserLocation userLocation,
  ) {
    return lots.map((lot) {
      final distance = calculateDistance(
        userLocation.lat,
        userLocation.lng,
        lot.lat,
        lot.lng,
      );
      return lot.copyWith(distance: distance);
    }).toList();
  }

  // 거리순 정렬
  List<ParkingLot> sortByDistance(List<ParkingLot> lots) {
    final sorted = List<ParkingLot>.from(lots);
    sorted.sort((a, b) {
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });
    return sorted;
  }
}
