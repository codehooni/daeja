import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../../core/widgets/map/parking_marker.dart';
import '../../domain/models/parking_lot.dart';

class ParkingMarkerHelper {
  // 발렛 주차장 상수
  static const Color valetBorderColor = Color(0xFF4F4C95);
  static const double valetBorderWidth = 2.0;

  /// 단일 마커 생성
  static Future<NMarker> createMarker({
    required BuildContext context,
    required ParkingLot parkingLot,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) async {
    final icon = await _createIcon(
      context: context,
      availableSpots: parkingLot.availableSpots,
      parkingType: parkingLot.type,
      isDarkMode: isDarkMode,
      name: parkingLot.name,
    );

    final marker = NMarker(
      id: parkingLot.id,
      position: NLatLng(parkingLot.lat, parkingLot.lng),
      icon: icon,
    );

    marker.setOnTapListener((_) => onTap());
    return marker;
  }

  /// 여러 마커 지도에 추가
  static Future<List<NMarker>> addMarkers({
    required BuildContext context,
    required NaverMapController controller,
    required List<ParkingLot> parkingLots,
    required Function(ParkingLot) onMarkerTap,
    required bool isDarkMode,
  }) async {
    final markers = <NMarker>[];

    for (final parkingLot in parkingLots) {
      // 좌표 검증 (0,0은 스킵)
      if (parkingLot.lat == 0 || parkingLot.lng == 0) {
        continue;
      }

      // BuildContext가 여전히 유효한지 확인
      if (!context.mounted) break;

      final marker = await createMarker(
        context: context,
        parkingLot: parkingLot,
        onTap: () => onMarkerTap(parkingLot),
        isDarkMode: isDarkMode,
      );

      await controller.addOverlay(marker);
      markers.add(marker);
    }

    return markers;
  }

  /// 모든 마커 제거 - 리스트만 클리어 (API 호출 안함)
  static void clearMarkers({required List<NMarker> markers}) {
    // deleteOverlay 호출하지 않음 (Naver Map이 dispose 시 자동으로 정리)
    markers.clear();
  }

  /// 마커 아이콘 생성 (색상 로직 포함)
  static Future<NOverlayImage> _createIcon({
    required BuildContext context,
    required int availableSpots,
    required ParkingLotType parkingType,
    required bool isDarkMode,
    required String name,
  }) async {
    // 색상 결정: 절대 개수 기준
    Color backgroundColor;
    if (availableSpots == 0) {
      backgroundColor = Color(0xFFD96C68); // 만차
    } else if (availableSpots <= 5) {
      backgroundColor = Color(0xFFEBB252); // 거의 만차
    } else {
      backgroundColor = Color(0xFF4A997B); // 여유
    }

    // 테마에 따른 색상 조정
    if (isDarkMode) {
      backgroundColor = Color.lerp(backgroundColor, Colors.black, 0.3)!;
    } else {
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.2)!;
    }

    // 발렛 주차장 테두리
    final isValet = parkingType == ParkingLotType.valet;
    final borderColor = isValet
        ? valetBorderColor
        : (isDarkMode ? Colors.grey[300]! : Colors.black54);
    final borderWidth = isValet ? valetBorderWidth : 1.5;
    if (isValet) backgroundColor = Color(0xFF7779EC);

    return ParkingMarkerWidget.createIcon(
      context: context,
      availableSpots: availableSpots,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      isValet: isValet,
      name: name,
    );
  }
}
