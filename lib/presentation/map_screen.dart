import 'package:daeja/features/location/presentation/providers/location_providers.dart';
import 'package:daeja/features/parking/domain/models/parking_lot.dart';
import 'package:daeja/features/parking/presentation/helpers/parking_marker_helper.dart';
import 'package:daeja/features/parking/presentation/providers/parking_providers.dart';
import 'package:daeja/features/parking/presentation/widgets/parking_detail_bottom_sheet.dart';
import 'package:daeja/features/user/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../features/parking/presentation/widgets/parking_bottom_sheet_factory.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;
  List<NMarker> _markers = [];
  bool _isMapReady = false;

  @override
  void dispose() {
    _isMapReady = false; // 먼저 플래그 설정
    _mapController = null; // 컨트롤러 무효화
    _markers.clear(); // 마커 리스트만 클리어 (삭제 API 호출 안함)
    super.dispose();
  }

  /// 지도 준비 완료 콜백
  void _onMapReady(NaverMapController controller) async {
    setState(() {
      _mapController = controller;
      _isMapReady = true;
    });

    // 마커 로드
    _loadMarkers();

    // 내 위치 오버레이 설정
    await _setupLocationOverlay();
  }

  /// 주차장 마커 로드
  Future<void> _loadMarkers() async {
    if (_mapController == null || !_isMapReady || !mounted) return;

    try {
      debugPrint('🗺️ 마커 로딩 시작...');

      // Provider의 future를 직접 await (완료될 때까지 기다림)
      final parkingLots = await ref.read(parkingLotsProvider.future);

      // 각 단계마다 mounted 및 컨트롤러 체크
      if (!mounted || _mapController == null || !_isMapReady) return;

      debugPrint('🗺️ 주차장 데이터 로드 완료: ${parkingLots.length}개');

      // 기존 마커 클리어 (삭제 API 호출 안함)
      _markers.clear();

      if (!mounted || _mapController == null || !_isMapReady) return;

      // 테마 모드 확인
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      debugPrint('🗺️ 마커 생성 시작...');

      // 새 마커 추가
      final newMarkers = await ParkingMarkerHelper.addMarkers(
        context: context,
        controller: _mapController!,
        parkingLots: parkingLots,
        onMarkerTap: _onMarkerTap,
        isDarkMode: isDarkMode,
      );

      debugPrint('🗺️ 마커 생성 완료: ${newMarkers.length}개');

      // 최종 setState 전 마지막 체크
      if (!mounted || _mapController == null || !_isMapReady) return;

      setState(() {
        _markers = newMarkers;
      });
    } catch (error, stack) {
      debugPrint('❌ 마커 로드 실패: $error');
      debugPrint('Stack trace: $stack');
    }
  }

  /// 마커 탭 핸들러
  void _onMarkerTap(ParkingLot parkingLot) {
    debugPrint('🎯 마커 클릭: ${parkingLot.name}');

    // 바텀 시트 표시
    ParkingBottomSheetFactory.show(context, parkingLot);
  }

  /// 위치 오버레이 설정 및 현재 위치 표시
  Future<void> _setupLocationOverlay() async {
    if (_mapController == null || !_isMapReady || !mounted) return;

    try {
      debugPrint('📍 위치 오버레이 설정 시작...');

      // LocationOverlay 가져오기
      final locationOverlay = _mapController!.getLocationOverlay();

      // 사용자 현재 위치 조회
      final userLocationAsync = ref.read(userLocationProvider1);

      await userLocationAsync.when(
        data: (userLocation) async {
          debugPrint('📍 사용자 위치: ${userLocation.lat}, ${userLocation.lng}');

          // LocationOverlay 위치 설정
          locationOverlay.setPosition(
            NLatLng(userLocation.lat, userLocation.lng),
          );

          // LocationOverlay 표시
          locationOverlay.setIsVisible(true);

          // 카메라를 사용자 위치로 이동
          final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(userLocation.lat, userLocation.lng),
            zoom: 15,
          );
          await _mapController!.updateCamera(cameraUpdate);

          debugPrint('✅ 위치 오버레이 설정 완료');
        },
        loading: () {
          debugPrint('📍 위치 로딩 중...');
        },
        error: (error, _) {
          debugPrint('❌ 위치 가져오기 실패: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ LocationOverlay 설정 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // parkingLotsProvider 감시
    final parkingLotsAsync = ref.watch(parkingLotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: '대자'.text.color(Colors.blue).size(22).bold.make(),
        centerTitle: false,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_2_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          NaverMap(
            onMapReady: _onMapReady,
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(33.4996, 126.5312), // 제주도 중심
                zoom: 11,
              ),
              locationButtonEnable: true, // 내 위치 버튼 활성화
            ),
          ),
          // 로딩 인디케이터
          if (parkingLotsAsync.isLoading)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('주차장 로딩 중...'),
                  ],
                ),
              ),
            ),
          // 에러 표시
          if (parkingLotsAsync.hasError)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('데이터 로드 실패'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
