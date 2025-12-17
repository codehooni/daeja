import '../../domain/models/user_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasource/local/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDatasource _datasource;

  LocationRepositoryImpl(this._datasource);

  @override
  Future<UserLocation> getCurrentLocation() async {
    final position = await _datasource.getCurrentPosition();
    return UserLocation(
      lat: position.latitude,
      lng: position.longitude,
      fetchedAt: DateTime.now(),
      accuracy: position.accuracy,
    );
  }

  @override
  Stream<UserLocation> watchLocation() {
    return _datasource.watchPosition().map((position) {
      return UserLocation(
        lat: position.latitude,
        lng: position.longitude,
        fetchedAt: DateTime.now(),
        accuracy: position.accuracy,
      );
    });
  }
}
