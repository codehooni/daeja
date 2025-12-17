import 'dart:math';
import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../feature/parking/model/parking_cluster.dart';

class ParkingClusteringHelper {
  // 줌 레벨별 클러스터링 거리 임계값 (미터)
  static double getClusterDistance(double zoom) {
    if (zoom < 11) return 5000; // 5km
    if (zoom < 13) return 2000; // 2km
    if (zoom < 14) return 1000; // 1km
    if (zoom < 15) return 500; // 500m
    if (zoom < 16) return 200; // 200m
    return 0; // 16 이상은 클러스터링 안 함
  }

  // 두 좌표 간 거리 계산 (Haversine 공식, 미터 단위)
  static double calculateDistance(NLatLng pos1, NLatLng pos2) {
    const double earthRadius = 6371000; // 지구 반경 (미터)

    final lat1 = pos1.latitude * pi / 180;
    final lat2 = pos2.latitude * pi / 180;
    final dLat = (pos2.latitude - pos1.latitude) * pi / 180;
    final dLon = (pos2.longitude - pos1.longitude) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // 클러스터링 수행
  static List<ParkingCluster> cluster(
    List<ParkingLot> parkingLots,
    double zoomLevel,
  ) {
    final clusterDistance = getClusterDistance(zoomLevel);

    // 클러스터링 안 하는 줌 레벨이면 각 주차장을 개별 클러스터로 반환
    if (clusterDistance == 0) {
      return parkingLots
          .where((lot) => lot.xCrdn != null && lot.yCrdn != null)
          .map(
            (lot) => ParkingCluster(
              parkingLots: [lot],
              center: NLatLng(lot.yCrdn!, lot.xCrdn!),
            ),
          )
          .toList();
    }

    // 유효한 좌표를 가진 주차장만 필터링
    final validLots = parkingLots
        .where((lot) => lot.xCrdn != null && lot.yCrdn != null)
        .toList();

    final List<ParkingCluster> clusters = [];
    final Set<String> clustered = {}; // 이미 클러스터에 포함된 주차장 ID

    for (var i = 0; i < validLots.length; i++) {
      final lot = validLots[i];

      // 이미 클러스터에 포함된 주차장은 스킵
      if (clustered.contains(lot.id)) continue;

      // 현재 주차장을 중심으로 가까운 주차장 찾기
      final List<ParkingLot> nearbyLots = [lot];
      clustered.add(lot.id);

      for (var j = i + 1; j < validLots.length; j++) {
        final otherLot = validLots[j];

        if (clustered.contains(otherLot.id)) continue;

        final distance = calculateDistance(
          NLatLng(lot.yCrdn!, lot.xCrdn!),
          NLatLng(otherLot.yCrdn!, otherLot.xCrdn!),
        );

        if (distance <= clusterDistance) {
          nearbyLots.add(otherLot);
          clustered.add(otherLot.id);
        }
      }

      // 클러스터 중심 좌표 계산 (평균)
      final centerLat =
          nearbyLots.map((l) => l.yCrdn!).reduce((a, b) => a + b) /
          nearbyLots.length;
      final centerLon =
          nearbyLots.map((l) => l.xCrdn!).reduce((a, b) => a + b) /
          nearbyLots.length;

      clusters.add(
        ParkingCluster(
          parkingLots: nearbyLots,
          center: NLatLng(centerLat, centerLon),
        ),
      );
    }

    return clusters;
  }
}
