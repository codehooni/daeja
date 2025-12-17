class UserLocationEntity {
  final double lat;
  final double lng;
  final DateTime fetchedAt;
  final double? accuracy;

  const UserLocationEntity({
    required this.lat,
    required this.lng,
    required this.fetchedAt,
    this.accuracy,
  });
}
