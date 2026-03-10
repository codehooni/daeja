import '../models/reservation.dart';

// 사용자 관점의 예약 Repository
abstract class UserReservationRepository {
  // 새 예약 생성
  Future<Reservation> createReservation({
    required String userId,
    required String vehicleId,
    required String parkingLotId,
    required DateTime expectedArrival,
    DateTime? expectedExit,
    String? notes,
    // Denormalized fields
    String? vehiclePlate,
    String? vehicleManufacturer,
    String? vehicleModel,
    String? parkingLotName,
    double? parkingLotLat,
    double? parkingLotLng,
    // Pricing fields
    int? valetFee,
    int? dailyParkingFee,
  });

  // 내 모든 예약 조회
  Future<List<Reservation>> getMyReservations(String userId);

  // 특정 예약 상세 조회
  Future<Reservation?> getReservation(String reservationId);

  // 예약 취소
  Future<void> cancelReservation(String reservationId);

  // 예약 수정 (시간, 차량 등)
  Future<void> updateReservation({
    required String reservationId,
    DateTime? expectedArrival,
    DateTime? expectedExit,
    String? vehicleId,
    String? notes,
  });

  // 출차 요청
  Future<void> requestExit(String reservationId, DateTime expectedExitTime);

  // 활성 예약 조회 (진행 중인 예약만)
  Future<List<Reservation>> getActiveReservations(String userId);

  // 예약 내역 조회 (완료/취소된 예약)
  Future<List<Reservation>> getReservationHistory(String userId);

  // 특정 예약 실시간 모니터링
  Stream<Reservation?> watchReservation(String reservationId);

  // 내 모든 예약 실시간 모니터링
  Stream<List<Reservation>> watchMyReservations(String userId);
}
