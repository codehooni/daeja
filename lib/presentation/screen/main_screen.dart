import 'dart:developer';

import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_state.dart';
import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/presentation/helper/parking_marker_helper.dart';
import 'package:daeja/presentation/widget/my_bottom_navigation_item.dart';
import 'package:daeja/presentation/screen/home_screen.dart';
import 'package:daeja/presentation/screen/settings_screen.dart';
import 'package:daeja/presentation/widget/my_floating_action_button.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/presentation/widget/sheet/parking_detail_sheet.dart';
import 'package:daeja/presentation/widget/sheet/parking_list_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  NaverMapController? mapController;

  List<NMarker> _markers = [];

  // Bottom App Bar Screens
  List<Widget> get _screens => [
    HomeScreen(
      mapController: mapController,
      onMapReady: _onMapReady,
      onRefresh: _onRefresh,
      onMyLocation: _onMyLocation,
    ),

    const SettingsScreen(),
  ];

  // 새로고침
  Future<void> _onRefresh() async {
    context.read<ParkingLotCubit>().fetchParkingLots();
  }

  // 내 위치로 이동
  Future<void> _onMyLocation() async {
    if (mapController == null) return;

    final userLocation = context.read<UserLocationProvider>();
    await mapController!.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(userLocation.latitude, userLocation.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  // 페이지 전환 컨트롤
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 주변 주차장 버튼 클릭
  void _onFabPressed() {
    ParkingListSheet.show(context);
  }

  @override
  void initState() {
    super.initState();

    // 앱 시작 시 주차장 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParkingLotCubit>().fetchParkingLots();
    });
  }

  // 네이버 맵 로드시 실행
  void _onMapReady(NaverMapController controller) async {
    setState(() {
      mapController = controller;
    });

    // 현재 위치로 초기 이동
    final userLocation = context.read<UserLocationProvider>();

    // 내 위치 표시 활성화
    controller.setLocationTrackingMode(NLocationTrackingMode.follow);

    controller.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(userLocation.latitude, userLocation.longitude),
          zoom: 15,
        ),
      ),
    );

    // 마커들 추가하기
    final parkingState = context.read<ParkingLotCubit>().state;
    log('ParkingState : $parkingState');
    if (parkingState is ParkingLotResult) {
      await _loadMarkers(parkingState.parkingLots);
    }
    if (parkingState is ParkingLotInitial) {
      await _loadMarkers(parkingState.parkingLots);
    }
  }

  Future<void> _loadMarkers(List<ParkingLot> parkingLots) async {
    if (mapController == null) return;

    // 기존 마커 제거
    await ParkingMarkerHelper.clearMarkers(mapController!, _markers);

    // 새 마커 추가
    _markers = await ParkingMarkerHelper.addMarkers(
      context,
      mapController!,
      parkingLots,
      _onMarkerTap,
    );
  }

  void _onMarkerTap(ParkingLot parking) {
    ParkingDetailSheet.show(context, parking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: BlocListener<ParkingLotCubit, ParkingLotState>(
        listener: (context, state) {
          if (state is ParkingLotResult) {
            _loadMarkers(state.parkingLots);
          }
          if (state is ParkingLotInitial) {
            _loadMarkers(state.parkingLots);
          }
        },
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),

      // Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        // Modern Desing
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,

        // Bottom Navigation Bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyBottomNavigationItem(
              isMe: _currentIndex == 0,
              icon: Icons.home,
              onPressed: () => _onItemTapped(0),
            ),
            SizedBox(),

            MyBottomNavigationItem(
              isMe: _currentIndex == 1,
              icon: Icons.settings,
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: _onFabPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    // 마커 정리
    if (mapController != null) {
      ParkingMarkerHelper.clearMarkers(mapController!, _markers);
    }
    super.dispose();
  }
}
