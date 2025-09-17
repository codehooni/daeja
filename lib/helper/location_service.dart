import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationHelper {
  static final loc.Location _location = loc.Location();

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