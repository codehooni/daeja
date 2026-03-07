import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:velocity_x/velocity_x.dart';

class ParkingMarkerWidget extends StatelessWidget {
  final int availableSpots;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool isValet;

  const ParkingMarkerWidget({
    super.key,
    required this.availableSpots,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.isValet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isValet ? const EdgeInsets.all(4.0) : const EdgeInsets.all(0),
      child:
          HStack([
                (isValet ? 'V' : 'P').text.size(13).white.bold.make(),
                4.widthBox,
                '$availableSpots'.text.size(12).white.semiBold.make(),
              ])
              .centered()
              .py4()
              .px12()
              .box
              .roundedLg
              .color(backgroundColor)
              .withShadow([
                ?isValet
                    ? BoxShadow(
                        color: backgroundColor.withOpacity(0.8),
                        blurRadius: 4.0,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      )
                    : null,
              ])
              .border(color: borderColor, width: borderWidth)
              .make(),
    );
  }

  /// Naver Map용 NOverlayImage 생성
  static Future<NOverlayImage> createIcon({
    required BuildContext context,
    required int availableSpots,
    required Color backgroundColor,
    required Color borderColor,
    double borderWidth = 2.0,
    required bool isValet,
  }) async {
    return NOverlayImage.fromWidget(
      context: context,
      widget: ParkingMarkerWidget(
        availableSpots: availableSpots,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        isValet: isValet,
      ),
    );
  }
}
