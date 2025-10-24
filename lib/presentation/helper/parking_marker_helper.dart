import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ParkingMarkerHelper {
  // 마커 생성
  static Future<NMarker> createMarker(
    BuildContext context,
    ParkingLot parking,
    VoidCallback onTap,
  ) async {
    final icon = await _createIconWithNumber(context, parking.totalRemaining);

    final marker = NMarker(
      id: parking.id,
      position: NLatLng(parking.yCrdn!, parking.xCrdn!),
      icon: icon,
    );

    marker.setOnTapListener((_) => onTap());
    return marker;
  }

  // 마커 아이콘
  static Future<NOverlayImage> _createIconWithNumber(
    BuildContext context,
    int available,
  ) async {
    // 색상 결정
    Color backgroundColor;
    if (available == 0) {
      backgroundColor = Colors.red; // 만차
    } else if (available <= 5) {
      backgroundColor = Colors.orange; // 거의 만차
    } else {
      backgroundColor = Colors.green; // 여유
    }

    return NOverlayImage.fromWidget(
      context: context,
      widget: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Text(
            available.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
        ),
      ),
      size: Size(40.0, 40.0),
    );
  }

  // 마커 추가
  static Future<List<NMarker>> addMarkers(
    BuildContext context,
    NaverMapController controller,
    List<ParkingLot> parkingLots,
    Function(ParkingLot) onMarkerTap,
  ) async {
    final markers = <NMarker>[];

    for (var parking in parkingLots) {
      if (parking.xCrdn == null || parking.yCrdn == null) {
        continue;
      }

      final marker = await createMarker(
        context,
        parking,
        () => onMarkerTap(parking),
      );

      await controller.addOverlay(marker);
      markers.add(marker);
    }

    return markers;
  }

  // 마커 제거
  static Future<void> clearMarkers(
    NaverMapController controller,
    List<NMarker> markers,
  ) async {
    for (var marker in markers) {
      await controller.deleteOverlay(marker.info);
    }
    markers.clear();
  }
}
