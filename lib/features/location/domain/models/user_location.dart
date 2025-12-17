class UserLocation {
  final double lat;
  final double lng;
  final DateTime fetchedAt;
  final double? accuracy;

  const UserLocation({
    required this.lat,
    required this.lng,
    required this.fetchedAt,
    this.accuracy,
  });
}
