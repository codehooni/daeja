import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/utils/logger.dart';
import '../../entities/reservation.dart';
import '../user_reservation_datasource.dart';

class UserReservationDatasourceFirebase implements UserReservationDatasource {
  final FirebaseFirestore _firestore;
  final String _collection = 'reservations';

  UserReservationDatasourceFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Reservation> createReservation(Reservation reservation) async {
    try {
      Log.d('예약 생성: userId=${reservation.visitorId}');

      // 자동 생성될 document ID를 먼저 받아옴
      final docRef = _firestore.collection(_collection).doc();

      final data = {
        'id': docRef.id, // 자동 생성된 ID를 data에 포함
        'visitorId': reservation.visitorId,
        'visitorVehicleId': reservation.visitorVehicleId,
        'visitorVehiclePlate': reservation.visitorVehiclePlate,
        'parkingLotId': reservation.parkingLotId,
        'parkingLotName': reservation.parkingLotName,
        'expectedArrival': DateTime.parse(reservation.expectedArrival),
        'expectedExit': reservation.expectedExit != null
            ? DateTime.parse(reservation.expectedExit!)
            : null,
        'status': reservation.status,
        'createdAt': FieldValue.serverTimestamp(),
        'notes': reservation.notes,
      };

      await docRef.set(data);

      final createdDoc = await docRef.get();
      Log.s('예약 생성 완료: ${docRef.id}');
      return _reservationFromFirestore(createdDoc);
    } catch (e) {
      Log.e('예약 생성 실패', e);
      rethrow;
    }
  }

  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      Log.d('사용자 예약 조회: userId=$userId');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('visitorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final reservations =
          querySnapshot.docs.map((doc) => _reservationFromFirestore(doc)).toList();

      Log.s('사용자 예약 조회 완료: ${reservations.length}개');
      return reservations;
    } catch (e) {
      Log.e('사용자 예약 조회 실패', e);
      rethrow;
    }
  }

  @override
  Future<Reservation?> getReservationById(String reservationId) async {
    try {
      Log.d('예약 ID로 조회: reservationId=$reservationId');

      final doc =
          await _firestore.collection(_collection).doc(reservationId).get();

      if (!doc.exists) {
        Log.d('예약을 찾을 수 없습니다');
        return null;
      }

      Log.s('예약 조회 완료');
      return _reservationFromFirestore(doc);
    } catch (e) {
      Log.e('예약 조회 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      Log.d('예약 취소: reservationId=$reservationId');

      await _firestore.collection(_collection).doc(reservationId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Log.s('예약 취소 완료');
    } catch (e) {
      Log.e('예약 취소 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> updateReservation(
    String reservationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      Log.d('예약 수정: reservationId=$reservationId');

      // DateTime 필드를 Timestamp로 변환
      final firestoreUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        if (value is String &&
            (key.contains('Arrival') || key.contains('Exit'))) {
          firestoreUpdates[key] = DateTime.parse(value);
        } else {
          firestoreUpdates[key] = value;
        }
      });

      firestoreUpdates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(reservationId)
          .update(firestoreUpdates);

      Log.s('예약 수정 완료');
    } catch (e) {
      Log.e('예약 수정 실패', e);
      rethrow;
    }
  }

  @override
  Stream<Reservation?> watchReservation(String reservationId) {
    try {
      Log.d('예약 Stream 시작: reservationId=$reservationId');

      return _firestore
          .collection(_collection)
          .doc(reservationId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return _reservationFromFirestore(snapshot);
      });
    } catch (e) {
      Log.e('예약 Stream 실패', e);
      rethrow;
    }
  }

  @override
  Stream<List<Reservation>> watchUserReservations(String userId) {
    try {
      Log.d('사용자 예약 Stream 시작: userId=$userId');

      return _firestore
          .collection(_collection)
          .where('visitorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
        final reservations = querySnapshot.docs
            .map((doc) => _reservationFromFirestore(doc))
            .toList();
        Log.d('사용자 예약 Stream 업데이트: ${reservations.length}개');
        return reservations;
      });
    } catch (e) {
      Log.e('사용자 예약 Stream 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> requestExit(String reservationId, DateTime expectedExitTime) async {
    try {
      Log.d('출차 요청: reservationId=$reservationId, expectedExitTime=$expectedExitTime');

      await _firestore.collection(_collection).doc(reservationId).update({
        'status': 'exitRequested',
        'expectedExit': expectedExitTime,  // DateTime 객체로 저장 (Firestore가 Timestamp로 변환)
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Log.s('출차 요청 완료');
    } catch (e) {
      Log.e('출차 요청 실패', e);
      rethrow;
    }
  }

  /// Firestore DocumentSnapshot을 Reservation 모델로 변환
  Reservation _reservationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Reservation(
      id: data['id'] as String? ?? doc.id, // data에 id가 있으면 사용, 없으면 doc.id 사용
      visitorId: data['visitorId'] as String,
      visitorVehicleId: data['visitorVehicleId'] as String,
      visitorVehiclePlate: data['visitorVehiclePlate'] as String?,
      parkingLotId: data['parkingLotId'] as String,
      parkingLotName: data['parkingLotName'] as String?,
      expectedArrival:
          (data['expectedArrival'] as Timestamp).toDate().toIso8601String(),
      expectedExit: data['expectedExit'] != null
          ? (data['expectedExit'] as Timestamp).toDate().toIso8601String()
          : null,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      notes: data['notes'] as String?,
      assignedSpotId: data['assignedSpotId'] as String?,
      handledByStaffId: data['handledByStaffId'] as String?,
      handledByStaffName: data['handledByStaffName'] as String?,
      handledByStaffPhone: data['handledByStaffPhone'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      actualArrival: data['actualArrival'] != null
          ? (data['actualArrival'] as Timestamp).toDate().toIso8601String()
          : null,
      actualExit: data['actualExit'] != null
          ? (data['actualExit'] as Timestamp).toDate().toIso8601String()
          : null,
      logs: data['logs'] as String?,
    );
  }
}
