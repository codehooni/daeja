import '../../../../core/utils/logger.dart';
import '../../domain/models/reservation.dart';
import '../../domain/repositories/user_reservation_repository.dart';
import '../datasource/user_reservation_datasource.dart';
import '../entities/reservation.dart' as entity;
import '../mappers/reservation_mapper.dart';

class UserReservationRepositoryImpl implements UserReservationRepository {
  final UserReservationDatasource _datasource;

  UserReservationRepositoryImpl(this._datasource);

  @override
  Future<Reservation> createReservation({
    required String userId,
    required String vehicleId,
    required String parkingLotId,
    required DateTime expectedArrival,
    DateTime? expectedExit,
    String? notes,
    String? vehiclePlate,
    String? parkingLotName,
    double? parkingLotLat,
    double? parkingLotLng,
  }) async {
    try {
      Log.d('Repository: 예약 생성 - userId=$userId, lotId=$parkingLotId');

      final reservation = entity.Reservation(
        id: '', // Firestore에서 자동 생성
        visitorId: userId,
        visitorVehicleId: vehicleId,
        visitorVehiclePlate: vehiclePlate,
        parkingLotId: parkingLotId,
        parkingLotName: parkingLotName,
        parkingLotLat: parkingLotLat,
        parkingLotLng: parkingLotLng,
        expectedArrival: expectedArrival.toIso8601String(),
        expectedExit: expectedExit?.toIso8601String(),
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
        notes: notes,
      );

      final createdEntity = await _datasource.createReservation(reservation);
      return reservationEntityToModel(createdEntity);
    } catch (e) {
      Log.e('Repository: 예약 생성 실패', e);
      rethrow;
    }
  }

  @override
  Future<List<Reservation>> getMyReservations(String userId) async {
    try {
      Log.d('Repository: 내 예약 조회 - userId=$userId');
      final entities = await _datasource.getUserReservations(userId);
      return entities.map((e) => reservationEntityToModel(e)).toList();
    } catch (e) {
      Log.e('Repository: 내 예약 조회 실패', e);
      rethrow;
    }
  }

  @override
  Future<Reservation?> getReservation(String reservationId) async {
    try {
      Log.d('Repository: 예약 상세 조회 - reservationId=$reservationId');
      final entity = await _datasource.getReservationById(reservationId);
      return entity != null ? reservationEntityToModel(entity) : null;
    } catch (e) {
      Log.e('Repository: 예약 상세 조회 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      Log.d('Repository: 예약 취소 - reservationId=$reservationId');
      await _datasource.cancelReservation(reservationId);
    } catch (e) {
      Log.e('Repository: 예약 취소 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> updateReservation({
    required String reservationId,
    DateTime? expectedArrival,
    DateTime? expectedExit,
    String? vehicleId,
    String? notes,
  }) async {
    try {
      Log.d('Repository: 예약 수정 - reservationId=$reservationId');

      final updates = <String, dynamic>{};
      if (expectedArrival != null) {
        updates['expectedArrival'] = expectedArrival.toIso8601String();
      }
      if (expectedExit != null) {
        updates['expectedExit'] = expectedExit.toIso8601String();
      }
      if (vehicleId != null) {
        updates['visitorVehicleId'] = vehicleId;
      }
      if (notes != null) {
        updates['notes'] = notes;
      }

      await _datasource.updateReservation(reservationId, updates);
    } catch (e) {
      Log.e('Repository: 예약 수정 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> requestExit(String reservationId, DateTime expectedExitTime) async {
    try {
      Log.d('Repository: 출차 요청 - reservationId=$reservationId, expectedExitTime=$expectedExitTime');
      await _datasource.requestExit(reservationId, expectedExitTime);
      Log.s('Repository: 출차 요청 성공');
    } catch (e) {
      Log.e('Repository: 출차 요청 실패', e);
      rethrow;
    }
  }

  @override
  Future<List<Reservation>> getActiveReservations(String userId) async {
    try {
      Log.d('Repository: 활성 예약 조회 - userId=$userId');
      final allReservations = await _datasource.getUserReservations(userId);

      // 활성 상태만 필터링 (pending, approved, confirmed, exitRequested)
      final activeStatuses = {'pending', 'approved', 'confirmed', 'exitRequested'};
      final activeReservations = allReservations
          .where((r) => activeStatuses.contains(r.status))
          .toList();

      return activeReservations.map((e) => reservationEntityToModel(e)).toList();
    } catch (e) {
      Log.e('Repository: 활성 예약 조회 실패', e);
      rethrow;
    }
  }

  @override
  Future<List<Reservation>> getReservationHistory(String userId) async {
    try {
      Log.d('Repository: 예약 내역 조회 - userId=$userId');
      final allReservations = await _datasource.getUserReservations(userId);

      // 완료/취소된 예약만 필터링
      final completedStatuses = {'completed', 'cancelled', 'no_show'};
      final historyReservations = allReservations
          .where((r) => completedStatuses.contains(r.status))
          .toList();

      return historyReservations.map((e) => reservationEntityToModel(e)).toList();
    } catch (e) {
      Log.e('Repository: 예약 내역 조회 실패', e);
      rethrow;
    }
  }

  @override
  Stream<Reservation?> watchReservation(String reservationId) {
    try {
      Log.d('Repository: 예약 Stream 시작 - reservationId=$reservationId');
      return _datasource.watchReservation(reservationId).map(
            (entity) => entity != null ? reservationEntityToModel(entity) : null,
          );
    } catch (e) {
      Log.e('Repository: 예약 Stream 실패', e);
      rethrow;
    }
  }

  @override
  Stream<List<Reservation>> watchMyReservations(String userId) {
    try {
      Log.d('Repository: 내 예약 Stream 시작 - userId=$userId');
      return _datasource.watchUserReservations(userId).map(
            (entities) => entities.map((e) => reservationEntityToModel(e)).toList(),
          );
    } catch (e) {
      Log.e('Repository: 내 예약 Stream 실패', e);
      rethrow;
    }
  }
}
