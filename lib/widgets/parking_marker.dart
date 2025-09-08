import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../models/parking_lot.dart';

double occupancyRate(ParkingLot lot) =>
    lot.totalSpaces == 0 ? 1.0 : 1 - (lot.availableSpaces / lot.totalSpaces);

Color getMarkerColor(ParkingLot lot) {
  final rate = occupancyRate(lot);
  if (rate <= 0.33) return Colors.green;
  if (rate <= 0.66) return Colors.yellow.shade700;
  if (rate < 1.0) return Colors.red;
  return Colors.grey;
}

Future<NOverlayImage> buildParkingMarker(
  ParkingLot lot,
  BuildContext context,
) async {
  final color = getMarkerColor(lot);

  return await NOverlayImage.fromWidget(
    widget: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: lot.availableSpaces
            .toString()
            .text
            .color(Colors.black)
            .bold
            .size(12.0)
            .make(),
      ),
    ),
    context: context,
  );
}
