import 'dart:async';

import 'package:daeja/features/parking/model/parking_cluster.dart';
import 'package:daeja/features/parking/model/parking_lot.dart';
import 'package:daeja/features/settings/provider/theme_provider.dart';
import 'package:daeja/presentation/helper/parking_clustering_helper.dart';
import 'package:daeja/presentation/helper/parking_marker_helper.dart';
import 'package:daeja/presentation/widget/my_bottom_navigation_item.dart';
import 'package:daeja/presentation/screen/home_screen.dart';
import 'package:daeja/presentation/screen/settings_screen.dart';
import 'package:daeja/presentation/widget/my_floating_action_button.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/presentation/widget/sheet/cluster_list_sheet.dart';
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
  double _currentZoom = 15.0;
  Timer? _debounceTimer;

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
      onCameraChange: _onCameraChange,
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
      await _loadMarkersWithClustering(parkingLots);
    }
  }

  // 카메라 변경 시 호출
  void _onCameraChange(NCameraUpdateReason reason, bool animated) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateMarkersAfterCameraChange();
    });
  }

  // 카메라 변경 후 마커 업데이트
  Future<void> _updateMarkersAfterCameraChange() async {
    if (mapController == null) return;

    final cameraPosition = await mapController!.getCameraPosition();
    final newZoom = cameraPosition.zoom;

    // 줌 레벨이 변경되었으면 마커 재생성
    if ((newZoom - _currentZoom).abs() > 0.5) {
      setState(() {
        _currentZoom = newZoom;
      });

      final parkingLots = ref.read(parkingLotProvider).asData?.value;
      if (parkingLots != null) {
        await _loadMarkersWithClustering(parkingLots);
      }
    }
  }

  // 클러스터링을 적용한 마커 로드
  Future<void> _loadMarkersWithClustering(List<ParkingLot> parkingLots) async {
    if (mapController == null) return;

    final isDarkMode = ref.read(isDarkModeProvider);

    // 기존 마커 제거
    await ParkingMarkerHelper.clearMarkers(mapController!, _markers);

    // 클러스터링 수행
    final clusters = ParkingClusteringHelper.cluster(parkingLots, _currentZoom);

    // 클러스터 마커 생성
    _markers = [];
    for (final cluster in clusters) {
      final marker = cluster.isSingleParkingLot
          ? await ParkingMarkerHelper.createMarker(
              context,
              cluster.singleParkingLot!,
              () => _onMarkerTap(cluster.singleParkingLot!),
              isDarkMode: isDarkMode,
            )
          : await ParkingMarkerHelper.createClusterMarker(
              context,
              cluster,
              () => _onClusterTap(cluster),
              isDarkMode: isDarkMode,
            );

      await mapController!.addOverlay(marker);
      _markers.add(marker);
    }
  }

  // 기존 메서드 (테마 변경 시 사용)
  Future<void> _loadMarkers(List<ParkingLot> parkingLots) async {
    await _loadMarkersWithClustering(parkingLots);
  }

  void _onMarkerTap(ParkingLot parking) {
    ParkingDetailSheet.show(context, parking);
  }

  // 클러스터 탭 처리
  void _onClusterTap(ParkingCluster cluster) async {
    if (mapController == null) return;

    // 클러스터 영역으로 줌 인
    final newZoom = _currentZoom + 2;
    await mapController!.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(target: cluster.center, zoom: newZoom.clamp(0, 21)),
      ),
    );

    // 클러스터 리스트 바텀시트 표시
    ClusterListSheet.show(
      context,
      cluster,
      onParkingTap: _onParkingSelected,
    );
  }

  @override
  void dispose() {
    // 마커 정리
    if (mapController != null) {
      ParkingMarkerHelper.clearMarkers(mapController!, _markers);
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 주차장 데이터 변경 감지
    ref.listen<AsyncValue<List<ParkingLot>>>(parkingLotProvider, (
      _,
      next,
    ) {
      next.whenData((parkingLots) {
        _loadMarkers(parkingLots);
      });
    });

    // 테마 변경 감지
    ref.listen<bool>(isDarkModeProvider, (_, next) {
      final parkingLots = ref.read(parkingLotProvider).asData?.value;
      if (parkingLots != null) {
        _loadMarkers(parkingLots);
      }
    });

    final asyncParkingLots = ref.watch(parkingLotProvider);

    return switch (asyncParkingLots) {
      AsyncData() => Scaffold(
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
}
