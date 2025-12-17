import 'package:daeja/past/presentation/widget/map/refresh_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'compass_button.dart';
import 'my_location_button.dart';
import 'zoom_buttons.dart';

class MapControlButtons extends StatelessWidget {
  final NaverMapController? mapController;
  final VoidCallback? onRefresh;
  final VoidCallback? onMyLocation;

  const MapControlButtons({
    super.key,
    this.mapController,
    this.onRefresh,
    this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    const basicPadding = 16.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom + basicPadding;
    final topPadding = MediaQuery.of(context).padding.top + basicPadding;

    return Stack(
      children: [
        // 오른쪽 위 - 새로고침, 나침반
        Positioned(
          right: basicPadding,
          top: topPadding,
          child: Column(
            children: [
              RefreshButton(onPressed: onRefresh),
              SizedBox(height: 10.0),
              CompassButton(mapController: mapController),
            ],
          ),
        ),

        // 왼쪽 아래 - 내 위치
        Positioned(
          left: basicPadding,
          bottom: bottomPadding,
          child: MyLocationButton(onPressed: onMyLocation),
        ),

        // 오른쪽 아래 - 줌
        Positioned(
          right: basicPadding,
          bottom: bottomPadding,
          child: ZoomButtons(mapController: mapController),
        ),
      ],
    );
  }
}
