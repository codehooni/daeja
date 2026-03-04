import '../../data/entities/reservation.dart' as entity;
import '../../domain/models/reservation.dart' as model;

/// String을 ReservationStatus enum으로 변환
model.ReservationStatus _statusFromString(String status) {
  try {
    return model.ReservationStatus.values.byName(status);
  } catch (e) {
    // 알 수 없는 상태는 pending으로 기본값 설정
    return model.ReservationStatus.pending;
  }
}

/// ReservationStatus enum을 String으로 변환
String _statusToString(model.ReservationStatus status) {
  return status.name;
}

/// Reservation Entity를 Domain Model로 변환
model.Reservation reservationEntityToModel(
  entity.Reservation entityReservation,
) {
  return model.Reservation(
    id: entityReservation.id,
    visitorId: entityReservation.visitorId,
    visitorVehicleId: entityReservation.visitorVehicleId,
    visitorVehiclePlate: entityReservation.visitorVehiclePlate,
    parkingLotId: entityReservation.parkingLotId,
    parkingLotName: entityReservation.parkingLotName,
    parkingLotLat: entityReservation.parkingLotLat,
    parkingLotLng: entityReservation.parkingLotLng,
    expectedArrival: entityReservation.expectedArrival,
    expectedExit: entityReservation.expectedExit,
    status: _statusFromString(entityReservation.status),
    createdAt: entityReservation.createdAt,
    notes: entityReservation.notes,
    assignedSpotId: entityReservation.assignedSpotId,
    handledByStaffId: entityReservation.handledByStaffId,
    handledByStaffName: entityReservation.handledByStaffName,
    handledByStaffPhone: entityReservation.handledByStaffPhone,
    profileImageUrl: entityReservation.profileImageUrl,
    actualArrival: entityReservation.actualArrival,
    actualExit: entityReservation.actualExit,
    logs: entityReservation.logs,
  );
}

/// Reservation Domain Model을 Entity로 변환
entity.Reservation reservationModelToEntity(
  model.Reservation modelReservation,
) {
  return entity.Reservation(
    id: modelReservation.id,
    visitorId: modelReservation.visitorId,
    visitorVehicleId: modelReservation.visitorVehicleId,
    visitorVehiclePlate: modelReservation.visitorVehiclePlate,
    parkingLotId: modelReservation.parkingLotId,
    parkingLotName: modelReservation.parkingLotName,
    parkingLotLat: modelReservation.parkingLotLat,
    parkingLotLng: modelReservation.parkingLotLng,
    expectedArrival: modelReservation.expectedArrival,
    expectedExit: modelReservation.expectedExit,
    status: _statusToString(modelReservation.status),
    createdAt: modelReservation.createdAt,
    notes: modelReservation.notes,
    assignedSpotId: modelReservation.assignedSpotId,
    handledByStaffId: modelReservation.handledByStaffId,
    handledByStaffName: modelReservation.handledByStaffName,
    handledByStaffPhone: modelReservation.handledByStaffPhone,
    profileImageUrl: modelReservation.profileImageUrl,
    actualArrival: modelReservation.actualArrival,
    actualExit: modelReservation.actualExit,
    logs: modelReservation.logs,
  );
}
