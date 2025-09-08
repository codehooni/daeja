import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../models/parking_lot.dart';

// 마커 캐시 (성능 최적화)
final Map<String, NOverlayImage> _markerCache = {};

double occupancyRate(ParkingLot lot) =>
    lot.totalSpaces == 0 ? 1.0 : 1 - (lot.availableSpaces / lot.totalSpaces);

Color getMarkerColor(ParkingLot lot) {
  final rate = occupancyRate(lot);
  if (rate <= 0.33) return Colors.green;
  if (rate <= 0.66) return Colors.yellow.shade700;
  if (rate < 1.0) return Colors.red;
  return Colors.grey;
}

Future<NOverlayImage> buildParkingMarker(
  ParkingLot lot,
  BuildContext context,
) async {
  final color = getMarkerColor(lot);
  
  // 캐시 키 생성 (색상 + 잔여 주차면수)
  final cacheKey = '${color.value}_${lot.availableSpaces}';
  
  // 캐시에서 먼저 확인
  if (_markerCache.containsKey(cacheKey)) {
    return _markerCache[cacheKey]!;
  }

  // 새 마커 생성
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
  
  // 캐시에 저장 (최대 50개까지)
  if (_markerCache.length > 50) {
    _markerCache.clear(); // 캐시 클리어
  }
  _markerCache[cacheKey] = markerImage;
  
  return markerImage;
}

// 캐시 클리어 함수 (메모리 관리)
void clearMarkerCache() {
  _markerCache.clear();
}
