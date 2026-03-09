import 'parking_spot_entity.dart';
import 'parking_zone_entity.dart';

class PrivateParkingEntity {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final String? ownerId;
  final String hours;
  final String pricing;
  final String type;
  final bool isValetSupported;
  final List<String>? images;
  final List<ParkingSpotEntity> parkingSpots;
  final List<ParkingZoneEntity> parkingZones;
  final String? accountNumber;
  final String? tel;

  // 요금 정보
  final int? basePrice;
  final int? unitTime;
  final int? unitPrice;

  // 예약 안내 정보
  final String? reservationInfo;

  const PrivateParkingEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.hours,
    required this.pricing,
    required this.type,
    required this.isValetSupported,
    required this.parkingSpots,
    required this.parkingZones,
    this.ownerId,
    this.images,
    this.basePrice,
    this.unitTime,
    this.unitPrice,
    this.reservationInfo,
    this.accountNumber,
    this.tel,
  });

  factory PrivateParkingEntity.fromJson(Map<String, dynamic> json) {
    return PrivateParkingEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      ownerId: json['owner_id'] as String?,
      hours: json['hours'] as String? ?? '24h',
      pricing: json['pricing'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'outdoor',
      isValetSupported: json['is_valet_supported'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      basePrice: json['base_price'] as int?,
      unitTime: json['unit_time'] as int?,
      unitPrice: json['unit_price'] as int?,
      reservationInfo: json['reservation_info'] as String?,
      parkingSpots:
          (json['parking_spots'] as List<dynamic>?)
              ?.map(
                (e) => ParkingSpotEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      parkingZones:
          (json['parking_zones'] as List<dynamic>?)
              ?.map(
                (e) => ParkingZoneEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      accountNumber: json['account_number'] as String?,
      tel: json['tel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'lat': lat,
    'lon': lon,
    'owner_id': ownerId,
    'hours': hours,
    'pricing': pricing,
    'type': type,
    'is_valet_supported': isValetSupported,
    'images': images,
    'base_price': basePrice,
    'unit_time': unitTime,
    'unit_price': unitPrice,
    'reservation_info': reservationInfo,
    'parking_spots': parkingSpots.map((e) => e.toJson()).toList(),
    'parking_zones': parkingZones.map((e) => e.toJson()).toList(),
    'account_number': accountNumber,
    'tel': tel,
  };
}
