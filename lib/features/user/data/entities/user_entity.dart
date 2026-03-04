import 'vehicle_entity.dart';

class UserEntity {
  final String uid;
  final String? name;
  final String phone;
  final List<VehicleEntity>? vehicles;
  final String? createdAt;
  final String? fcmToken;
  final bool notificationsEnabled;

  const UserEntity({
    required this.uid,
    required this.phone,
    this.name,
    this.vehicles,
    this.createdAt,
    this.fcmToken,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phone': phone,
        'name': name,
        'vehicles': vehicles?.map((vehicle) => vehicle.toJson()).toList(),
        'createdAt': createdAt,
        'fcmToken': fcmToken,
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        uid: json['uid'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String?,
        vehicles: (json['vehicles'] as List?)
            ?.map((vehicle) => VehicleEntity.fromJson(vehicle as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as String?,
        fcmToken: json['fcmToken'] as String?,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );
}
