import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ParkingCluster {
  final List<ParkingLot> parkingLots;
  final NLatLng center;

  ParkingCluster({required this.parkingLots, required this.center});

  // 클러스터 내 총 잔여 면수
  int get totalRemaining {
    return parkingLots.fold(0, (sum, lot) => sum + lot.totalRemaining);
  }

  // 클러스터 내 총 주차 면수
  int get totalCapacity {
    return parkingLots.fold(0, (sum, lot) => sum + (lot.wholNpls ?? 0));
  }

  // 잔여 비율 (0.0 ~ 1.0)
  double get remainingRatio {
    if (totalCapacity == 0) return 0.0;
    return totalRemaining / totalCapacity;
  }

  // 발렛 주차장 포함 여부
  bool get hasValetParking {
    return parkingLots.any((lot) => lot.parkingType == 'valet');
  }

  // 클러스터 내 주차장 개수
  int get count => parkingLots.length;

  // 단일 주차장인지 여부
  bool get isSingleParkingLot => parkingLots.length == 1;

  // 단일 주차장인 경우 해당 주차장 반환
  ParkingLot? get singleParkingLot {
    return isSingleParkingLot ? parkingLots.first : null;
  }
}
