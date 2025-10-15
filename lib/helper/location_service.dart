import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationHelper {
  static final loc.Location _location = loc.Location();

  // 위치 권한 상태 확인
  static Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      // 권한 상태 확인
      loc.PermissionStatus permissionGranted = await _location.hasPermission();

      if (permissionGranted == loc.PermissionStatus.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      } else if (permissionGranted == loc.PermissionStatus.denied) {
        return LocationPermissionStatus.denied;
      } else {
        return LocationPermissionStatus.granted;
      }
    } catch (e) {
      print('Error checking permission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  static Future<Position?> getPosition() async {
    try {
      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;

      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled');
          return null;
        }
      }

      permissionGranted = await _location.hasPermission();

      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted == loc.PermissionStatus.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permissionGranted == loc.PermissionStatus.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// 제주도 위치 여부 확인
  /// 제주도 대략 위도: 33.2°~33.6°, 경도: 126.1°~126.9°
  static bool isInJejuIsland(Position position) {
    const double minLat = 33.2;
    const double maxLat = 33.6;
    const double minLng = 126.1;
    const double maxLng = 126.9;

    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLng &&
        position.longitude <= maxLng;
  }

  /// 제주시청 기본 좌표
  static const double jejuCityHallLat = 33.4996;
  static const double jejuCityHallLng = 126.5312;
}