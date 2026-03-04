import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../domain/models/parking_lot.dart';

/// 길찾기 지도 선택 바텀시트
class NavigationSelectionSheet extends StatelessWidget {
  final Coords coords;
  final String title;
  final List<AvailableMap> availableMaps;

  const NavigationSelectionSheet({
    super.key,
    required this.coords,
    required this.availableMaps,
    required this.title,
  });

  /// 길찾기 바텀시트 표시 (ParkingLot)
  static Future<void> show(BuildContext context, ParkingLot parkingLot) async {
    final availableMaps = await MapLauncher.installedMaps;

    // 설치된 지도 앱이 없는 경우
    if (availableMaps.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설치된 지도 앱이 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final coords = Coords(parkingLot.lat, parkingLot.lng);
    final title = parkingLot.name;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NavigationSelectionSheet(
        coords: coords,
        availableMaps: availableMaps,
        title: title,
      ),
    );
  }

  /// 길찾기 바텀시트 표시 (직접 좌표 전달)
  static Future<void> showWithCoords(
    BuildContext context, {
    required double lat,
    required double lng,
    required String title,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    // 설치된 지도 앱이 없는 경우
    if (availableMaps.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설치된 지도 앱이 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final coords = Coords(lat, lng);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NavigationSelectionSheet(
        coords: coords,
        availableMaps: availableMaps,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VStack([
      // 드래그 핸들
      VxBox()
          .width(40)
          .height(4)
          .gray300
          .roundedSM
          .make()
          .centered()
          .pSymmetric(v: 12),

      // 헤더
      '지도 선택'
          .text
          .size(20)
          .bold
          .color(Colors.black87)
          .make()
          .centered()
          .pSymmetric(v: 8),

      16.heightBox,

      // 지도 앱 리스트
      SingleChildScrollView(
        child: VStack(
          [
            for (var map in availableMaps)
              VStack([
                HStack([
                  // 지도 앱 아이콘
                  SvgPicture.asset(
                    map.icon,
                    height: 32,
                    width: 32,
                  ),
                  16.widthBox,

                  // 지도 앱 이름
                  map.mapName.text
                      .size(16)
                      .medium
                      .color(Colors.black87)
                      .make()
                      .expand(),

                  // 화살표
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ])
                    .p16()
                    .box
                    .white
                    .roundedLg
                    .make()
                    .onInkTap(() {
                  Navigator.pop(context);
                  map.showDirections(
                    destination: coords,
                    destinationTitle: title,
                    directionsMode: DirectionsMode.driving,
                  );
                }),
                8.heightBox,
              ]),
          ],
        ).pSymmetric(h: 20),
      ),

      // 하단 패딩 (Safe Area)
      MediaQuery.of(context).padding.bottom.heightBox,
    ])
        .box
        .white
        .customRounded(
          const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        )
        .make();
  }
}
