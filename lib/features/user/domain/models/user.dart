import 'vehicle.dart';

class User {
  final String uid;
  final String? name;
  final String phone;
  final List<Vehicle>? vehicles;
  final DateTime? createdAt;
  final String? fcmToken;
  final bool notificationsEnabled;

  const User({
    required this.uid,
    required this.phone,
    this.name,
    this.vehicles,
    this.createdAt,
    this.fcmToken,
    this.notificationsEnabled = true, // 기본값: 알림 켜짐
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'phone': phone,
    'name': name,
    'vehicles': vehicles?.map((vehicle) => vehicle.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'fcmToken': fcmToken,
    'notificationsEnabled': notificationsEnabled,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    phone: json['phone'],
    name: json['name'],
    vehicles: (json['vehicles'] as List?)
        ?.map((vehicle) => Vehicle.fromJson(vehicle))
        .toList(),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    fcmToken: json['fcmToken'],
    notificationsEnabled: json['notificationsEnabled'] ?? true, // 기존 사용자 호환성
  );

  User copyWith({
    String? phone,
    String? name,
    List<Vehicle>? vehicles,
    DateTime? createdAt,
    Object? fcmToken = _undefined,
    bool? notificationsEnabled,
  }) {
    return User(
      uid: uid,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      vehicles: vehicles ?? this.vehicles,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken == _undefined ? this.fcmToken : fcmToken as String?,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// copyWith에서 null을 명시적으로 설정하기 위한 sentinel 값
const _undefined = Object();
