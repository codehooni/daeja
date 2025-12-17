import '../../domain/models/parking_cluster.dart';
import '../../domain/models/parking_lot.dart';

class ParkingClusteringService {
  List<ParkingCluster> clusterParkingLots(
    List<ParkingLot> lots,
    double zoomLevel,
  ) {
    if (zoomLevel > 14) {
      // 줌 레벨 높으면 클러스터링 안함
      return [];
    }

    // 간단한 그리드 기반 클러스터링
    final gridSize = _getGridSize(zoomLevel);
    final Map<String, List<ParkingLot>> grid = {};

    for (final lot in lots) {
      final gridX = (lot.lng / gridSize).floor();
      final gridY = (lot.lat / gridSize).floor();
      final key = '$gridX:$gridY';

      grid.putIfAbsent(key, () => []);
      grid[key]!.add(lot);
    }

    return grid.entries.where((e) => e.value.length > 1).map((e) {
      final clusterLots = e.value;
      final avgLat =
          clusterLots.map((l) => l.lat).reduce((a, b) => a + b) /
          clusterLots.length;
      final avgLng =
          clusterLots.map((l) => l.lng).reduce((a, b) => a + b) /
          clusterLots.length;
      final totalAvailable = clusterLots
          .map((l) => l.availableSpots)
          .reduce((a, b) => a + b);

      return ParkingCluster(
        id: e.key,
        lat: avgLat,
        lng: avgLng,
        parkingLots: clusterLots,
        totalAvailable: totalAvailable,
      );
    }).toList();
  }

  double _getGridSize(double zoomLevel) {
    if (zoomLevel < 10) return 0.1;
    if (zoomLevel < 12) return 0.05;
    return 0.02;
  }
}
