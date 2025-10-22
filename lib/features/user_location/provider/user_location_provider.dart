import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  // bool _isTracking = false;
  // StreamSubscription<Position>? _positionStreamSubscription;

  // 제주 시청 기본 좌표
  static const double jejuCityHallLat = 33.4996;
  static const double jejuCityHallLng = 126.5312;

  UserLocationProvider() {
    getCurrentLocation();
  }

  // 유저의 현재 위치 받아오기
  Position get currentPosition {
    return _currentPosition ??
        Position(
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
  }

  // bool get isTracking => _isTracking;

  double get latitude => currentPosition.latitude;
  double get longitude => currentPosition.longitude;
  double? get accuracy => _currentPosition?.accuracy;

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('위치 권한이 거부되었습니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('위치 권한이 영구적으로 거부되었습니다.');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentPosition = position;
      log('Success Get User Positon : $position', name: 'Get Location');
      notifyListeners();
    } catch (e) {
      log('위치 가져오기 오류: $e');
    }
  }
}
