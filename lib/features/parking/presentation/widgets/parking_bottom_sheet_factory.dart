import 'package:flutter/material.dart';

import '../../domain/models/parking_lot.dart';
import 'sheets/general_parking_sheet.dart';
import 'sheets/valet_parking_sheet.dart';

class ParkingBottomSheetFactory {
  // 인스턴스화 방지
  ParkingBottomSheetFactory._();
  static void show(BuildContext context, ParkingLot parkingLot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 여기서 타입에 따라 분기 처리
        switch (parkingLot.type) {
          case ParkingLotType.valet:
            return ValetParkingSheet(parkingLot: parkingLot);
          case ParkingLotType.public:
          case ParkingLotType.private:
          default:
            return GeneralParkingSheet(parkingLot: parkingLot);
        }
      },
    );
  }
}
