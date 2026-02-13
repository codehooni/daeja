class Car {
  final String id;
  final String carNumber;
  final String? manufacturer;
  final String? model;
  final String? color;
  final bool isDefault;

  const Car({
    required this.id,
    required this.carNumber,
    this.manufacturer,
    this.model,
    this.color,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'carNumber': carNumber,
        'manufacturer': manufacturer,
        'model': model,
        'color': color,
        'isDefault': isDefault,
      };

  factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: json['id'],
        carNumber: json['carNumber'],
        manufacturer: json['manufacturer'],
        model: json['model'],
        color: json['color'],
        isDefault: json['isDefault'] ?? false,
      );

  Car copyWith({
    String? id,
    String? carNumber,
    String? manufacturer,
    String? model,
    String? color,
    bool? isDefault,
  }) {
    return Car(
      id: id ?? this.id,
      carNumber: carNumber ?? this.carNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
