import 'car.dart';

class User {
  final String uid;
  final String phoneNumber;
  final String? name;
  final List<Car>? cars;
  final DateTime? createdAt;

  const User({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.cars,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'phoneNumber': phoneNumber,
    'name': name,
    'cars': cars?.map((car) => car.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    phoneNumber: json['phoneNumber'],
    name: json['name'],
    cars: (json['cars'] as List?)?.map((car) => Car.fromJson(car)).toList(),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
  );

  User copyWith({
    String? phoneNumber,
    String? name,
    List<Car>? cars,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      cars: cars ?? this.cars,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
