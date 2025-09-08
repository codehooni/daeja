import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationHelper {
  static final loc.Location _location = loc.Location();

  static Future<Position?> getPosition() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    permissionGranted = await _location.hasPermission();

    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permissionGranted == loc.PermissionStatus.deniedForever) {
      print("getPosition");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}