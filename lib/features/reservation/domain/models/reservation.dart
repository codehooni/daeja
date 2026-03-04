enum ReservationStatus {
  pending,       // 대기중
  approved,      // 승인됨
  confirmed,     // 입차 완료
  exitRequested, // 출차 요청
  completed,     // 출차 완료
  cancelled,     // 취소됨
}

class Reservation {
  final String id;

  // visitor
  final String visitorId;
  final String visitorVehicleId;
  final String? visitorVehiclePlate; // 차량 번호판 (denormalized)

  // parking lot
  final String parkingLotId;
  final String? parkingLotName; // 주차장 이름 (denormalized)
  final double? parkingLotLat; // 주차장 위도 (denormalized)
  final double? parkingLotLng; // 주차장 경도 (denormalized)

  // expected time
  final String expectedArrival;
  final String? expectedExit;

  final ReservationStatus status;
  final String createdAt;

  final String? notes;

  /// admin area
  final String? assignedSpotId;
  final String? handledByStaffId;
  final String? handledByStaffName; // 배정 기사 이름 (denormalized)
  final String? handledByStaffPhone; // 배정 기사 전화번호 (denormalized)
  final String? profileImageUrl; // 배정 기사 프로필 이미지 (denormalized)
  final String? actualArrival;
  final String? actualExit;

  final String? logs;

  Reservation({
    required this.id,
    required this.visitorId,
    required this.visitorVehicleId,
    this.visitorVehiclePlate,
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
    this.actualArrival,
    this.actualExit,
    this.logs,
  });
}
