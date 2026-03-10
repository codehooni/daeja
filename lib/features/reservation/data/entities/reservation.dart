class Reservation {
  final String id;

  // visitor
  final String visitorId;
  final String visitorVehicleId;
  final String? visitorVehiclePlate;
  final String? visitorVehicleManufacturer;
  final String? visitorVehicleModel;

  // parking lot
  final String parkingLotId;
  final String? parkingLotName;
  final double? parkingLotLat;
  final double? parkingLotLng;

  // expected time
  final String expectedArrival;
  final String? expectedExit;

  final String status;
  final String createdAt;

  final String? notes;

  /// admin area
  final String? assignedSpotId;
  final String? handledByStaffId;
  final String? handledByStaffName;
  final String? handledByStaffPhone;
  final String? profileImageUrl;
  final String? handledByStaffProfileUrl;
  final String? actualArrival;
  final String? actualExit;

  final String? logs;

  // 요금 정보 (발렛 예약에만 존재, 예약 시점의 요금 저장)
  final int? valetFee;          // 발렛 요금 (예: 20,000원)
  final int? dailyParkingFee;   // 일일 주차 요금 (예: 5,000원)

  Reservation({
    required this.id,
    required this.visitorId,
    required this.visitorVehicleId,
    this.visitorVehiclePlate,
    this.visitorVehicleManufacturer,
    this.visitorVehicleModel,
    required this.parkingLotId,
    this.parkingLotName,
    this.parkingLotLat,
    this.parkingLotLng,
    required this.expectedArrival,
    this.expectedExit,
    required this.status,
    required this.createdAt,
    this.notes,
    this.assignedSpotId,
    this.handledByStaffId,
    this.handledByStaffName,
    this.handledByStaffPhone,
    this.profileImageUrl,
    this.handledByStaffProfileUrl,
    this.actualArrival,
    this.actualExit,
    this.logs,
    this.valetFee,
    this.dailyParkingFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitorId': visitorId,
      'visitorVehicleId': visitorVehicleId,
      'visitorVehiclePlate': visitorVehiclePlate,
      'visitorVehicleManufacturer': visitorVehicleManufacturer,
      'visitorVehicleModel': visitorVehicleModel,
      'parkingLotId': parkingLotId,
      'parkingLotName': parkingLotName,
      'parkingLotLat': parkingLotLat,
      'parkingLotLng': parkingLotLng,
      'expectedArrival': expectedArrival,
      'expectedExit': expectedExit,
      'status': status,
      'createdAt': createdAt,
      'notes': notes,
      'assignedSpotId': assignedSpotId,
      'handledByStaffId': handledByStaffId,
      'handledByStaffName': handledByStaffName,
      'handledByStaffPhone': handledByStaffPhone,
      'profileImageUrl': profileImageUrl,
      'handledByStaffProfileUrl': handledByStaffProfileUrl,
      'actualArrival': actualArrival,
      'actualExit': actualExit,
      'logs': logs,
      'valetFee': valetFee,
      'dailyParkingFee': dailyParkingFee,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json['id'] as String,
    visitorId: json['visitorId'] as String,
    visitorVehicleId: json['visitorVehicleId'] as String,
    visitorVehiclePlate: json['visitorVehiclePlate'] as String?,
    visitorVehicleManufacturer: json['visitorVehicleManufacturer'] as String?,
    visitorVehicleModel: json['visitorVehicleModel'] as String?,
    parkingLotId: json['parkingLotId'] as String,
    parkingLotName: json['parkingLotName'] as String?,
    parkingLotLat: json['parkingLotLat'] as double?,
    parkingLotLng: json['parkingLotLng'] as double?,
    expectedArrival: json['expectedArrival'] as String,
    expectedExit: json['expectedExit'] as String?,
    status: json['status'] as String,
    createdAt: json['createdAt'] as String,
    notes: json['notes'] as String?,
    assignedSpotId: json['assignedSpotId'] as String?,
    handledByStaffId: json['handledByStaffId'] as String?,
    handledByStaffName: json['handledByStaffName'] as String?,
    handledByStaffPhone: json['handledByStaffPhone'] as String?,
    profileImageUrl: json['profileImageUrl'] as String?,
    handledByStaffProfileUrl: json['handledByStaffProfileUrl'] as String?,
    actualArrival: json['actualArrival'] as String?,
    actualExit: json['actualExit'] as String?,
    logs: json['logs'] as String?,
    valetFee: json['valetFee'] as int?,
    dailyParkingFee: json['dailyParkingFee'] as int?,
  );
}
