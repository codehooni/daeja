import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/presentation/widget/map/map_control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class HomeScreen extends StatelessWidget {
  final NaverMapController? mapController;
  final Function(NaverMapController)? onMapReady;
  final VoidCallback? onRefresh;
  final VoidCallback? onMyLocation;

  const HomeScreen({
    super.key,
    this.mapController,
    this.onMapReady,
    this.onRefresh,
    this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    final userLocation = context.watch<UserLocationProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // 네이버 맵
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(userLocation.latitude, userLocation.longitude),
                zoom: 15,
              ),
              locationButtonEnable: false,
            ),
            onMapReady: (controller) {
              onMapReady?.call(controller);
            },
          ),

          // 맵 컨트롤 버튼들
          MapControlButtons(
            mapController: mapController,
            onRefresh: onRefresh,
            onMyLocation: onMyLocation,
          ),
        ],
      ),
    );
  }
}
