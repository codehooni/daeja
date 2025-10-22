import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/features/parking_lot/data/repository/parking_lot_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class ParkingLotState {}

final class ParkingLotInitial extends ParkingLotState {
  final List<ParkingLot> parkingLots = ParkingLotRepository()
      .generateInitialParkingData();
}

final class ParkingLotLoading extends ParkingLotState {}

final class ParkingLotResult extends ParkingLotState {
  final List<ParkingLot> parkingLots;

  ParkingLotResult({required this.parkingLots});
}
