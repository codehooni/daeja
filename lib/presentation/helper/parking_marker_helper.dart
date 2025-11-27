import 'package:daeja/features/parking/model/parking_cluster.dart';
import 'package:daeja/features/parking/model/parking_lot.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ParkingMarkerHelper {
  // 발렛 주차장 테두리 색상 상수
  static const Color valetBorderColor = Color(0xFFFFD700); // 골드색
  static const double valetBorderWidth = 2.5;
  // 마커 생성
  static Future<NMarker> createMarker(
    BuildContext context,
    ParkingLot parking,
    VoidCallback onTap, {
    required bool isDarkMode,
  }) async {
    final icon = await _createIconWithNumber(
      context,
      parking.totalRemaining,
      parkingType: parking.parkingType,
      isDarkMode: isDarkMode,
    );

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
    int available, {
    String? parkingType,
    required bool isDarkMode,
  }) async {
    // 색상 결정
    Color backgroundColor;
    if (available == 0) {
      backgroundColor = Colors.red; // 만차
    } else if (available <= 5) {
      backgroundColor = Colors.orange; // 거의 만차
    } else {
      backgroundColor = Colors.green; // 여유
    }

    // 테마에 따라 색상 조정
    if (isDarkMode) {
      // 다크모드: 색상을 어둡게 조정
      backgroundColor = Color.lerp(backgroundColor, Colors.black, 0.3)!;
    } else {
      // 라이트모드: 색상을 밝게 조정
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.2)!;
    }

    // 발렛 주차장 여부 확인
    final isValetParking = parkingType == 'valet';

    // 테두리 색상 및 두께 결정
    final borderColor = isValetParking
        ? valetBorderColor
        : (isDarkMode ? Colors.grey[300]! : Colors.white);
    final borderWidth = isValetParking ? valetBorderWidth : 3.0;

    return NOverlayImage.fromWidget(
      context: context,
      widget: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(
          child: Text(
            available.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
              color: Colors.white,
            ),
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
    Function(ParkingLot) onMarkerTap, {
    required bool isDarkMode,
  }) async {
    final markers = <NMarker>[];

    for (var parking in parkingLots) {
      if (parking.xCrdn == null || parking.yCrdn == null) {
        continue;
      }

      final marker = await createMarker(
        context,
        parking,
        () => onMarkerTap(parking),
        isDarkMode: isDarkMode,
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
    for (final marker in markers) {
      try {
        await controller.deleteOverlay(marker.info);
      } catch (e) {
        // 이미 삭제된 마커는 무시
        print('마커 삭제 오류 (무시): $e');
      }
    }
  }

  // 클러스터 마커 생성
  static Future<NMarker> createClusterMarker(
    BuildContext context,
    ParkingCluster cluster,
    VoidCallback onTap, {
    required bool isDarkMode,
  }) async {
    final icon = await _createClusterIcon(
      context,
      cluster,
      isDarkMode: isDarkMode,
    );

    final marker = NMarker(
      id: 'cluster_${cluster.center.latitude}_${cluster.center.longitude}',
      position: cluster.center,
      icon: icon,
    );

    marker.setOnTapListener((_) => onTap());
    return marker;
  }

  // 클러스터 아이콘 생성
  static Future<NOverlayImage> _createClusterIcon(
    BuildContext context,
    ParkingCluster cluster, {
    required bool isDarkMode,
  }) async {
    // 잔여 비율로 색상 결정
    final ratio = cluster.remainingRatio;
    Color backgroundColor;

    if (ratio == 0) {
      backgroundColor = Colors.red; // 만차
    } else if (ratio < 0.3) {
      backgroundColor = Colors.orange; // 거의 만차
    } else {
      backgroundColor = Colors.green; // 여유
    }

    // 테마에 따라 색상 조정
    if (isDarkMode) {
      backgroundColor = Color.lerp(backgroundColor, Colors.black, 0.3)!;
    } else {
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.2)!;
    }

    // 발렛 주차장 포함 여부에 따라 테두리 결정
    final hasValet = cluster.hasValetParking;
    final borderColor = hasValet
        ? valetBorderColor
        : (isDarkMode ? Colors.grey[300]! : Colors.white);
    final borderWidth = hasValet ? valetBorderWidth : 3.0;

    return NOverlayImage.fromWidget(
      context: context,
      widget: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Stack(
          children: [
            // 주차장 개수 (상단)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${cluster.count}곳',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 총 잔여 면수 (중앙)
            Center(
              child: Text(
                cluster.totalRemaining.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      size: const Size(55.0, 55.0),
    );
  }
}
