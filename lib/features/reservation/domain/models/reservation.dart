import '../../../qr_code/domain/models/qr_code.dart';

class Reservation {
  final String id;

  // visitor
  final String visitorId;
  final String visitorVehicleId;

  // parking lot
  final String parkingLotId;

  // expected time
  final String expectedArrival;
  final String? expectedExit;

  final String status;
  final QrCode qrCode;
  final String createdAt;

  final String? notes;

  /// admin area
  final String? assignedSpotId;
  final String? handledByStaffId;
  final String? actualArrival;
  final String? actualExit;

  final String? logs;

  Reservation({
    required this.id,
    required this.visitorId,
    required this.visitorVehicleId,
    required this.parkingLotId,
    required this.expectedArrival,
    this.expectedExit,
    required this.status,
    required this.qrCode,
    required this.createdAt,
    this.notes,
    this.assignedSpotId,
    this.handledByStaffId,
    this.actualArrival,
    this.actualExit,
    this.logs,
  });
}
