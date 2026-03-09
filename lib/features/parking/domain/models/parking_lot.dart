enum ParkingLotType { public, private, valet }

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int totalSpots;
  final int availableSpots;
  final ParkingLotType type;
  final int? fee;
  final double? distance;
  final String? accountNumber;
  final String? tel;

  // 요금 정보
  final int? basePrice; // 기본 요금
  final int? unitTime; // 단위 시간 (분)
  final int? unitPrice; // 단위 요금

  // 예약 안내 정보 (발렛 서비스 관련)
  final String? reservationInfo; // 세차, 차량 인수 위치 등의 예약 관련 안내

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.totalSpots,
    required this.availableSpots,
    required this.type,
    this.fee,
    this.distance,
    this.basePrice,
    this.unitTime,
    this.unitPrice,
    this.reservationInfo,
    this.accountNumber,
    this.tel,
  });

  // 거리 정보 추가한 새 객체 반환
  ParkingLot copyWith({double? distance, String? reservationInfo}) {
    return ParkingLot(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      totalSpots: totalSpots,
      availableSpots: availableSpots,
      type: type,
      fee: fee,
      distance: distance ?? this.distance,
      basePrice: basePrice,
      unitTime: unitTime,
      unitPrice: unitPrice,
      reservationInfo: reservationInfo ?? this.reservationInfo,
      accountNumber: accountNumber,
      tel: tel,
    );
  }

  /// 날짜 기반 요금 계산 (발렛 주차용)
  /// [arrivalTime] 입차 시간
  /// [exitTime] 출차 시간
  /// 날짜가 바뀔 때마다 1일로 계산 (23:59 입차 → 00:01 출차 = 2일)
  int? calculateFeeByDate(DateTime arrivalTime, DateTime exitTime) {
    if (basePrice == null || unitTime == null || unitPrice == null) {
      return fee;
    }

    if (exitTime.isBefore(arrivalTime) ||
        exitTime.isAtSameMomentAs(arrivalTime)) {
      return 0;
    }

    // 입차 날짜와 출차 날짜의 차이 계산 (날짜만 비교)
    final arrivalDate = DateTime(
      arrivalTime.year,
      arrivalTime.month,
      arrivalTime.day,
    );
    final exitDate = DateTime(exitTime.year, exitTime.month, exitTime.day);

    // 날짜 차이 + 1 = 실제 사용 일수
    // 예: 1월 1일 입차 → 1월 1일 출차 = 1일
    // 예: 1월 1일 입차 → 1월 2일 출차 = 2일
    final daysDifference = exitDate.difference(arrivalDate).inDays + 1;

    // 발렛 기본요금 + (일수 × 일일 주차요금)
    // 예: 1일 = 20,000 + (1 × 5,000) = 25,000원
    // 예: 2일 = 20,000 + (2 × 5,000) = 30,000원
    int totalFee = basePrice! + (daysDifference * unitPrice!);

    return totalFee;
  }

  // 주차 시간 기반 요금 계산 (기존 시간 단위 계산)
  // [parkingMinutes] 주차 시간(분)
  int? calculateFee(int parkingMinutes) {
    if (basePrice == null || unitTime == null || unitPrice == null) {
      return fee; // 요금 정보가 없으면 기본 fee 반환
    }

    if (parkingMinutes <= 0) {
      return 0;
    }

    // 기본 요금 + 추가 요금
    int totalFee = basePrice!;

    // 기본 시간 초과 시 추가 요금 계산
    if (parkingMinutes > unitTime!) {
      final additionalMinutes = parkingMinutes - unitTime!;
      final additionalUnits = (additionalMinutes / unitTime!).ceil();
      totalFee += additionalUnits * unitPrice!;
    }

    return totalFee;
  }

  @override
  String toString() {
    return 'ParkingLot{name: $name, type: $type}';
  }
}
