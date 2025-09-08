import 'dart:math' as math;
import '../models/parking_lot.dart';

class ClusterPoint {
  final double latitude;
  final double longitude;
  final List<ParkingLot> parkingLots;
  final bool isCluster;

  ClusterPoint({
    required this.latitude,
    required this.longitude,
    required this.parkingLots,
    this.isCluster = false,
  });

  // 클러스터 내 총 주차면수
  int get totalSpaces => parkingLots.fold(0, (sum, lot) => sum + lot.totalSpaces);
  
  // 클러스터 내 총 잔여 주차면수
  int get totalAvailableSpaces => parkingLots.fold(0, (sum, lot) => sum + lot.availableSpaces);
  
  // 클러스터 크기
  int get size => parkingLots.length;
}

class MarkerClustering {
  static const int _minClusterSize = 2;

  // 줌 레벨에 따른 클러스터링 거리 조정
  static double _getClusterDistance(double zoomLevel) {
    // 줌 레벨이 높을수록 클러스터링 거리를 줄임
    if (zoomLevel >= 16) return 0.0005; // 매우 가까운 거리에서만 클러스터링
    if (zoomLevel >= 14) return 0.001;
    if (zoomLevel >= 12) return 0.002;
    if (zoomLevel >= 10) return 0.005;
    return 0.01; // 낮은 줌 레벨에서는 넓은 범위 클러스터링
  }

  // 두 좌표 간의 거리 계산 (단순 유클리드 거리)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    final double dx = lat1 - lat2;
    final double dy = lng1 - lng2;
    return math.sqrt(dx * dx + dy * dy);
  }

  // 주차장 목록을 클러스터링
  static List<ClusterPoint> clusterParkingLots(
    List<ParkingLot> parkingLots,
    double zoomLevel,
  ) {
    if (parkingLots.isEmpty) return [];

    final clusterDistance = _getClusterDistance(zoomLevel);
    final List<ClusterPoint> clusters = [];
    final List<bool> processed = List.filled(parkingLots.length, false);

    for (int i = 0; i < parkingLots.length; i++) {
      if (processed[i]) continue;

      final lot = parkingLots[i];
      final List<ParkingLot> clusterLots = [lot];
      processed[i] = true;

      // 주변의 가까운 주차장들을 찾아서 클러스터에 추가
      for (int j = i + 1; j < parkingLots.length; j++) {
        if (processed[j]) continue;

        final otherLot = parkingLots[j];
        final distance = _calculateDistance(
          lot.latitude,
          lot.longitude,
          otherLot.latitude,
          otherLot.longitude,
        );

        if (distance <= clusterDistance) {
          clusterLots.add(otherLot);
          processed[j] = true;
        }
      }

      // 클러스터 중심점 계산 (평균 좌표)
      final centerLat = clusterLots.fold(0.0, (sum, lot) => sum + lot.latitude) / clusterLots.length;
      final centerLng = clusterLots.fold(0.0, (sum, lot) => sum + lot.longitude) / clusterLots.length;

      clusters.add(ClusterPoint(
        latitude: centerLat,
        longitude: centerLng,
        parkingLots: clusterLots,
        isCluster: clusterLots.length >= _minClusterSize,
      ));
    }

    return clusters;
  }

  // 클러스터의 점유율 계산
  static double getClusterOccupancyRate(ClusterPoint cluster) {
    if (cluster.totalSpaces == 0) return 1.0;
    return 1.0 - (cluster.totalAvailableSpaces / cluster.totalSpaces);
  }
}