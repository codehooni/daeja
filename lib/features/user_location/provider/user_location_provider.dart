import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final userLocationProvider =
    AsyncNotifierProvider<UserLocationNotifier, Position>(() {
  return UserLocationNotifier();
});

class UserLocationNotifier extends AsyncNotifier<Position> {
  // 제주 시청 기본 좌표
  static const double jejuCityHallLat = 33.4996;
  static const double jejuCityHallLng = 126.5312;

  @override
  Future<Position> build() async {
    return await _getCurrentLocation();
  }

  // 기본 위치 반환
  Position get _defaultPosition => Position(
        longitude: jejuCityHallLng,
        latitude: jejuCityHallLat,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

  // 위치 새로고침
  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCurrentLocation());
  }

  // 유저의 현재 위치 받아오기
  Future<Position> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('위치 권한이 거부되었습니다.');
          return _defaultPosition;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('위치 권한이 영구적으로 거부되었습니다.');
        return _defaultPosition;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      log('Success Get User Position : $position', name: 'Get Location');
      return position;
    } catch (e) {
      log('위치 가져오기 오류: $e');
      return _defaultPosition;
    }
  }
}
