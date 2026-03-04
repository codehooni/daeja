import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ParkingMarkerWidget extends StatelessWidget {
  final int availableSpots;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const ParkingMarkerWidget({
    super.key,
    required this.availableSpots,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          availableSpots.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Naver Map용 NOverlayImage 생성
  static Future<NOverlayImage> createIcon({
    required BuildContext context,
    required int availableSpots,
    required Color backgroundColor,
    required Color borderColor,
    double borderWidth = 3.0,
  }) async {
    return NOverlayImage.fromWidget(
      context: context,
      widget: ParkingMarkerWidget(
        availableSpots: availableSpots,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      size: const Size(40.0, 40.0),
    );
  }
}
