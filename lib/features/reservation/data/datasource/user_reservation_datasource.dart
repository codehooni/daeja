import '../entities/reservation.dart';

/// User 관점의 예약 Datasource
abstract class UserReservationDatasource {
  Future<Reservation> createReservation(Reservation reservation);
  Future<List<Reservation>> getUserReservations(String userId);
  Future<Reservation?> getReservationById(String reservationId);
  Future<void> cancelReservation(String reservationId);
  Future<void> updateReservation(String reservationId, Map<String, dynamic> updates);
  Future<void> requestExit(String reservationId, DateTime expectedExitTime);
  Stream<Reservation?> watchReservation(String reservationId);
  Stream<List<Reservation>> watchUserReservations(String userId);
}
