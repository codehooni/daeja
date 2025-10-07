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
}