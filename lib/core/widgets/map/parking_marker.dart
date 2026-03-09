import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:velocity_x/velocity_x.dart';

class ParkingMarkerWidget extends StatelessWidget {
  final int availableSpots;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool isValet;
  final String name;

  const ParkingMarkerWidget({
    super.key,
    required this.availableSpots,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.isValet,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return isValet ? _buildValetMarker() : _buildNormalMarker();
  }

  /// Naver Map용 NOverlayImage 생성
  static Future<NOverlayImage> createIcon({
    required BuildContext context,
    required int availableSpots,
    required Color backgroundColor,
    required Color borderColor,
    double borderWidth = 2.0,
    required bool isValet,
    required String name,
  }) async {
    return NOverlayImage.fromWidget(
      context: context,
      widget: ParkingMarkerWidget(
        availableSpots: availableSpots,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        isValet: isValet,
        name: name,
      ),
    );
  }

  Widget _buildValetMarker() {
    return HStack([
          'V'.text
              .size(14)
              .color(backgroundColor)
              .bold
              .make()
              .p8()
              .box
              .roundedFull
              .white
              .make(),
          8.widthBox,
          VStack([
            name.text.size(9).white.make(),
            2.heightBox,
            '$availableSpots'.text.size(12).white.semiBold.make(),
          ]),
        ])
        .centered()
        .py4()
        .px8()
        .box
        .rounded
        .color(backgroundColor)
        .withShadow([
          BoxShadow(
            color: backgroundColor.withOpacity(0.8),
            blurRadius: 4.0,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ])
        .border(color: borderColor, width: borderWidth)
        .make()
        .p4();
  }

  Widget _buildNormalMarker() {
    return HStack([
          'P'.text.size(13).white.bold.make(),
          4.widthBox,
          '$availableSpots'.text.size(12).white.semiBold.make(),
        ])
        .centered()
        .py4()
        .px12()
        .box
        .roundedLg
        .color(backgroundColor)
        .border(color: borderColor, width: borderWidth)
        .make();
  }
}
