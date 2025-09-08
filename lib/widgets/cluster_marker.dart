import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../utils/marker_clustering.dart';

// 클러스터 마커 캐시
final Map<String, NOverlayImage> _clusterMarkerCache = {};

Color getClusterColor(ClusterPoint cluster) {
  if (!cluster.isCluster) {
    // 단일 주차장인 경우 기존 로직 사용
    final lot = cluster.parkingLots.first;
    final rate = lot.totalSpaces == 0 ? 1.0 : 1 - (lot.availableSpaces / lot.totalSpaces);
    if (rate <= 0.33) return Colors.green;
    if (rate <= 0.66) return Colors.yellow.shade700;
    if (rate < 1.0) return Colors.red;
    return Colors.grey;
  }

  // 클러스터인 경우 전체 점유율 기반
  final rate = MarkerClustering.getClusterOccupancyRate(cluster);
  if (rate <= 0.33) return Colors.green.shade600;
  if (rate <= 0.66) return Colors.orange.shade600;
  if (rate < 1.0) return Colors.red.shade600;
  return Colors.grey.shade600;
}

Future<NOverlayImage> buildClusterMarker(
  ClusterPoint cluster,
  BuildContext context,
) async {
  final color = getClusterColor(cluster);
  
  if (cluster.isCluster) {
    // 클러스터 마커 생성
    final cacheKey = '${color.value}_${cluster.size}_cluster';
    
    if (_clusterMarkerCache.containsKey(cacheKey)) {
      return _clusterMarkerCache[cacheKey]!;
    }

    final markerImage = await NOverlayImage.fromWidget(
      widget: Container(
        width: cluster.size > 10 ? 50 : 44,
        height: cluster.size > 10 ? 50 : 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: cluster.size
              .toString()
              .text
              .color(Colors.white)
              .bold
              .size(cluster.size > 10 ? 16.0 : 14.0)
              .make(),
        ),
      ),
      context: context,
    );

    // 캐시에 저장
    if (_clusterMarkerCache.length > 30) {
      _clusterMarkerCache.clear();
    }
    _clusterMarkerCache[cacheKey] = markerImage;
    
    return markerImage;
  } else {
    // 단일 주차장 마커 (기존 로직)
    final lot = cluster.parkingLots.first;
    final cacheKey = '${color.value}_${lot.availableSpaces}_single';
    
    if (_clusterMarkerCache.containsKey(cacheKey)) {
      return _clusterMarkerCache[cacheKey]!;
    }

    final markerImage = await NOverlayImage.fromWidget(
      widget: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: lot.availableSpaces
              .toString()
              .text
              .color(Colors.black)
              .bold
              .size(12.0)
              .make(),
        ),
      ),
      context: context,
    );

    // 캐시에 저장
    if (_clusterMarkerCache.length > 30) {
      _clusterMarkerCache.clear();
    }
    _clusterMarkerCache[cacheKey] = markerImage;
    
    return markerImage;
  }
}

// 클러스터 마커 캐시 클리어
void clearClusterMarkerCache() {
  _clusterMarkerCache.clear();
}