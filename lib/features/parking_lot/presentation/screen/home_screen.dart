import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  final NaverMapController? mapController;
  final Function(NaverMapController)? onMapReady;

  const HomeScreen({super.key, this.mapController, this.onMapReady});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 위치 정보 가져오기
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = context.watch<UserLocationProvider>();

    return Scaffold(
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(userLocation.latitude, userLocation.longitude),
            zoom: 13,
          ),
          locationButtonEnable: false,
          scrollGesturesEnable: true,
          zoomGesturesEnable: true,
        ),
        onMapReady: (controller) {
          widget.onMapReady?.call(controller);
        },
      ),
    );
  }
}
