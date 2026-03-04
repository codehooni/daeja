import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/models/reservation.dart';
import '../../domain/repositories/user_reservation_repository.dart';
import 'domain/repository_providers.dart';

/// 내 모든 예약 실시간 조회 Provider (Stream)
final myReservationsProvider = StreamProvider.family<List<Reservation>, String>((ref, userId) {
  final repository = ref.watch(userReservationRepositoryProvider);
  Log.d('내 예약 Stream 시작: userId=$userId');
  return repository.watchMyReservations(userId);
});

/// 활성 예약 조회 Provider (진행 중인 예약만)
final activeReservationsProvider = FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  final repository = ref.watch(userReservationRepositoryProvider);
  Log.d('활성 예약 조회: userId=$userId');
  return await repository.getActiveReservations(userId);
});

/// 예약 내역 조회 Provider (완료/취소된 예약)
final reservationHistoryProvider = FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  final repository = ref.watch(userReservationRepositoryProvider);
  Log.d('예약 내역 조회: userId=$userId');
  return await repository.getReservationHistory(userId);
});

/// 특정 예약 상세 조회 Provider
final reservationDetailProvider = FutureProvider.family<Reservation?, String>((ref, reservationId) async {
  final repository = ref.watch(userReservationRepositoryProvider);
  Log.d('예약 상세 조회: reservationId=$reservationId');
  return await repository.getReservation(reservationId);
});

/// 특정 예약 실시간 모니터링 Provider
final reservationStreamProvider = StreamProvider.family<Reservation?, String>((ref, reservationId) {
  final repository = ref.watch(userReservationRepositoryProvider);
  Log.d('예약 Stream 시작: reservationId=$reservationId');
  return repository.watchReservation(reservationId);
});

/// User Reservation Controller Provider
final userReservationControllerProvider = Provider<UserReservationController>((ref) {
  return UserReservationController(ref);
});

/// User Reservation Controller
class UserReservationController {
  final Ref ref;

  UserReservationController(this.ref);

  UserReservationRepository get _repository => ref.read(userReservationRepositoryProvider);

  /// 예약 생성
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
      Log.d('Controller: 예약 생성 - userId=$userId, lotId=$parkingLotId');
      final reservation = await _repository.createReservation(
        userId: userId,
        vehicleId: vehicleId,
        parkingLotId: parkingLotId,
        expectedArrival: expectedArrival,
        expectedExit: expectedExit,
        notes: notes,
        vehiclePlate: vehiclePlate,
        parkingLotName: parkingLotName,
        parkingLotLat: parkingLotLat,
        parkingLotLng: parkingLotLng,
      );
      Log.s('Controller: 예약 생성 성공 - ${reservation.id}');

      // 예약 생성 후 관련 Provider 갱신
      ref.invalidate(myReservationsProvider(userId));
      ref.invalidate(activeReservationsProvider(userId));

      return reservation;
    } catch (e) {
      Log.e('Controller: 예약 생성 실패', e);
      rethrow;
    }
  }

  /// 예약 취소
  Future<void> cancelReservation(String reservationId, String userId) async {
    try {
      Log.d('Controller: 예약 취소 - reservationId=$reservationId');
      await _repository.cancelReservation(reservationId);
      Log.s('Controller: 예약 취소 성공');

      // 예약 취소 후 관련 Provider 갱신
      ref.invalidate(myReservationsProvider(userId));
      ref.invalidate(activeReservationsProvider(userId));
      ref.invalidate(reservationHistoryProvider(userId));
      ref.invalidate(reservationDetailProvider(reservationId));
    } catch (e) {
      Log.e('Controller: 예약 취소 실패', e);
      rethrow;
    }
  }

  /// 예약 수정
  Future<void> updateReservation({
    required String reservationId,
    required String userId,
    DateTime? expectedArrival,
    DateTime? expectedExit,
    String? vehicleId,
    String? notes,
  }) async {
    try {
      Log.d('Controller: 예약 수정 - reservationId=$reservationId');
      await _repository.updateReservation(
        reservationId: reservationId,
        expectedArrival: expectedArrival,
        expectedExit: expectedExit,
        vehicleId: vehicleId,
        notes: notes,
      );
      Log.s('Controller: 예약 수정 성공');

      // 예약 수정 후 관련 Provider 갱신
      ref.invalidate(myReservationsProvider(userId));
      ref.invalidate(activeReservationsProvider(userId));
      ref.invalidate(reservationDetailProvider(reservationId));
    } catch (e) {
      Log.e('Controller: 예약 수정 실패', e);
      rethrow;
    }
  }

  /// 출차 요청
  Future<void> requestExit(String reservationId, String userId, DateTime expectedExitTime) async {
    try {
      Log.d('Controller: 출차 요청 - reservationId=$reservationId, expectedExitTime=$expectedExitTime');
      await _repository.requestExit(reservationId, expectedExitTime);
      Log.s('Controller: 출차 요청 성공');

      // 출차 요청 후 관련 Provider 갱신
      ref.invalidate(myReservationsProvider(userId));
      ref.invalidate(activeReservationsProvider(userId));
      ref.invalidate(reservationHistoryProvider(userId));
      ref.invalidate(reservationDetailProvider(reservationId));
    } catch (e) {
      Log.e('Controller: 출차 요청 실패', e);
      rethrow;
    }
  }

  /// 내 예약 목록 새로고침
  Future<void> refreshMyReservations(String userId) async {
    try {
      Log.d('Controller: 내 예약 새로고침 - userId=$userId');
      ref.invalidate(myReservationsProvider(userId));
    } catch (e) {
      Log.e('Controller: 새로고침 실패', e);
      rethrow;
    }
  }
}

/// 선택된 예약 Notifier
class SelectedReservationNotifier extends Notifier<Reservation?> {
  @override
  Reservation? build() {
    return null;
  }

  void select(Reservation reservation) {
    Log.d('예약 선택: ${reservation.id}');
    state = reservation;
  }

  void clear() {
    Log.d('예약 선택 해제');
    state = null;
  }
}

final selectedReservationProvider = NotifierProvider<SelectedReservationNotifier, Reservation?>(
  () => SelectedReservationNotifier(),
);
