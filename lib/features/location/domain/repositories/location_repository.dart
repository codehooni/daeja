import '../models/user_location.dart';

abstract class LocationRepository {
  Future<UserLocation> getCurrentLocation();
  Stream<UserLocation> watchLocation();
}
