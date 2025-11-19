import 'dart:developer';

import 'package:daeja/features/parking/model/parking_lot.dart';
import 'package:daeja/features/settings/provider/theme_provider.dart';
import 'package:daeja/presentation/helper/parking_marker_helper.dart';
import 'package:daeja/presentation/widget/my_bottom_navigation_item.dart';
import 'package:daeja/presentation/screen/home_screen.dart';
import 'package:daeja/presentation/screen/settings_screen.dart';
import 'package:daeja/presentation/widget/my_floating_action_button.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/presentation/widget/sheet/parking_detail_sheet.dart';
import 'package:daeja/presentation/widget/sheet/parking_list_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/parking/provider/parking_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  NaverMapController? mapController;

  List<NMarker> _markers = [];

  /*

  Bottom App Bar

  */

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

  // 페이지 전환 컨트롤
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /*

  Stack Buttons

  */

  // 새로고침
  Future<void> _onRefresh() async {
    ref.read(parkingLotProvider.notifier).refresh();
  }

  // 내 위치로 이동
  Future<void> _onMyLocation() async {
    if (mapController == null) return;

    final position = ref.read(userLocationProvider).asData?.value;
    if (position == null) return;

    await mapController!.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  /*

  Parking Lots Near my

  */

  // 주변 주차장 버튼 클릭
  void _onFabPressed() {
    ParkingListSheet.show(context, onParkingTap: _onParkingSelected);
  }

  Future<void> _onParkingSelected(ParkingLot parking) async {
    if (mapController == null) return;
    if (parking.xCrdn == null || parking.yCrdn == null) return;

    // 홈 화면 이동
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });

      await Future.delayed(Duration(milliseconds: 100));
    }

    // 카메라 이동
    await mapController!.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(parking.yCrdn!, parking.xCrdn!),
          zoom: 16.0,
        ),
      ),
    );

    // 카메라 이동 대기
    await Future.delayed(Duration(milliseconds: 500));

    // 상세 정보 Sheet
    if (mounted) {
      ParkingDetailSheet.show(context, parking);
    }
  }

  /*

  Load Naver Map

  */

  @override
  void initState() {
    super.initState();

    // 앱 시작 시 주차장 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parkingLotProvider.notifier).fetchParkingLots();
    });
  }

  // 네이버 맵 로드시 실행
  void _onMapReady(NaverMapController controller) async {
    setState(() {
      mapController = controller;
    });

    // 현재 위치로 초기 이동
    final position = ref.read(userLocationProvider).asData?.value;
    if (position == null) return;

    // 내 위치 표시 활성화
    controller.setLocationTrackingMode(NLocationTrackingMode.follow);

    controller.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    // 마커들 추가하기
    if (!mounted) return;
    final parkingLots = ref.read(parkingLotProvider).asData?.value;
    if (parkingLots != null) {
      await _loadMarkers(parkingLots);
    }
  }

  Future<void> _loadMarkers(List<ParkingLot> parkingLots) async {
    if (mapController == null) return;

    final isDarkMode = ref.read(isDarkModeProvider);

    // 기존 마커 제거
    await ParkingMarkerHelper.clearMarkers(mapController!, _markers);

    // 새 마커 추가
    _markers = await ParkingMarkerHelper.addMarkers(
      context,
      mapController!,
      parkingLots,
      _onMarkerTap,
      isDarkMode: isDarkMode,
    );
  }

  void _onMarkerTap(ParkingLot parking) {
    ParkingDetailSheet.show(context, parking);
  }

  @override
  Widget build(BuildContext context) {
    // 주차장 데이터 변경 감지
    ref.listen<AsyncValue<List<ParkingLot>>>(parkingLotProvider, (
      previous,
      next,
    ) {
      next.whenData((parkingLots) {
        _loadMarkers(parkingLots);
      });
    });

    final asyncParkingLots = ref.watch(parkingLotProvider);

    return switch (asyncParkingLots) {
      AsyncData(:final value) => Scaffold(
        extendBody: true,
        body: IndexedStack(index: _currentIndex, children: _screens),

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
      ),
      AsyncError(:final error) => Text('error: $error'),
      _ => const Center(child: CircularProgressIndicator()),
    };
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
