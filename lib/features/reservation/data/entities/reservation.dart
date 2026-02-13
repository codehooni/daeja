import '../../../qr_code/data/entities/qr_code.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_id': visitorId,
      'visitor_vehicle_id': visitorVehicleId,
      'parking_lot_id': parkingLotId,
      'expected_arrival': expectedArrival,
      'expected_exit': expectedExit,
      'status': status,
      'qr_code': qrCode.toJson(),
      'created_at': createdAt,
      'notes': notes,
      'assigned_spot_id': assignedSpotId,
      'handled_by_staff_id': handledByStaffId,
      'actual_arrival': actualArrival,
      'actual_exit': actualExit,
      'logs': logs,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json['id'] as String,
    visitorId: json['visitor_id'] as String,
    visitorVehicleId: json['visitor_vehicle_id'] as String,
    parkingLotId: json['parking_lot_id'] as String,
    expectedArrival: json['expected_arrival'] as String,
    expectedExit: json['expected_exit'] as String?,
    status: json['status'] as String,
    qrCode: QrCode.fromJson(json['qr_code'] as Map<String, dynamic>),
    createdAt: json['created_at'] as String,
    notes: json['notes'] as String?,
    assignedSpotId: json['assigned_spot_id'] as String?,
    handledByStaffId: json['handled_by_staff_id'] as String?,
    actualArrival: json['actual_arrival'] as String?,
    actualExit: json['actual_exit'] as String?,
    logs: json['logs'] as String?,
  );
}
