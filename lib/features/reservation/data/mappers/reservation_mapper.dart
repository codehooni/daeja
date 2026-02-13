import '../../../qr_code/data/entities/qr_code.dart' as entity;
import '../../../qr_code/domain/models/qr_code.dart' as model;
import '../../data/entities/reservation.dart' as entity;
import '../../domain/models/reservation.dart' as model;

/// QrCode Entity를 Domain Model로 변환
model.QrCode qrCodeEntityToModel(entity.QrCode entityQrCode) {
  return model.QrCode(
    qrCodeValue: entityQrCode.qrCodeValue,
    reservationId: entityQrCode.reservationId,
    visitorId: entityQrCode.visitorId,
    parkingLotId: entityQrCode.parkingLotId,
    expiresAt: entityQrCode.expiresAt,
  );
}

/// QrCode Domain Model을 Entity로 변환
entity.QrCode qrCodeModelToEntity(model.QrCode modelQrCode) {
  return entity.QrCode(
    qrCodeValue: modelQrCode.qrCodeValue,
    reservationId: modelQrCode.reservationId,
    visitorId: modelQrCode.visitorId,
    parkingLotId: modelQrCode.parkingLotId,
    expiresAt: modelQrCode.expiresAt,
  );
}

/// Reservation Entity를 Domain Model로 변환
model.Reservation reservationEntityToModel(entity.Reservation entityReservation) {
  return model.Reservation(
    id: entityReservation.id,
    visitorId: entityReservation.visitorId,
    visitorVehicleId: entityReservation.visitorVehicleId,
    parkingLotId: entityReservation.parkingLotId,
    expectedArrival: entityReservation.expectedArrival,
    expectedExit: entityReservation.expectedExit,
    status: entityReservation.status,
    qrCode: qrCodeEntityToModel(entityReservation.qrCode),
    createdAt: entityReservation.createdAt,
    notes: entityReservation.notes,
    assignedSpotId: entityReservation.assignedSpotId,
    handledByStaffId: entityReservation.handledByStaffId,
    actualArrival: entityReservation.actualArrival,
    actualExit: entityReservation.actualExit,
    logs: entityReservation.logs,
  );
}

/// Reservation Domain Model을 Entity로 변환
entity.Reservation reservationModelToEntity(model.Reservation modelReservation) {
  return entity.Reservation(
    id: modelReservation.id,
    visitorId: modelReservation.visitorId,
    visitorVehicleId: modelReservation.visitorVehicleId,
    parkingLotId: modelReservation.parkingLotId,
    expectedArrival: modelReservation.expectedArrival,
    expectedExit: modelReservation.expectedExit,
    status: modelReservation.status,
    qrCode: qrCodeModelToEntity(modelReservation.qrCode),
    createdAt: modelReservation.createdAt,
    notes: modelReservation.notes,
    assignedSpotId: modelReservation.assignedSpotId,
    handledByStaffId: modelReservation.handledByStaffId,
    actualArrival: modelReservation.actualArrival,
    actualExit: modelReservation.actualExit,
    logs: modelReservation.logs,
  );
}
