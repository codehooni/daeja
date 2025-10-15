import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/my_bottom_navigation_item.dart';
import '../providers/parking_provider.dart';
import '../helper/location_service.dart';
import '../helper/launch_map_helper.dart';
import '../models/parking_lot.dart';

import 'home_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  NaverMapController? _mapController;
  Position? _currentPosition;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onMapControllerReady: (controller) {
          _mapController = controller;
        },
      ),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _showNearbyParkingLots() async {
    final parkingProvider = Provider.of<ParkingProvider>(
      context,
      listen: false,
    );

    try {
      // 권한 상태 먼저 확인
      final permissionStatus = await LocationHelper.checkPermissionStatus();

      // 권한이 영구적으로 거부된 경우
      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        _showPermissionSettingsDialog();
        return;
      }

      // 위치 서비스가 비활성화된 경우
      if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
        _showLocationServiceDialog();
        return;
      }

      // 현재 위치 가져오기
      _currentPosition = await LocationHelper.getPosition();
      if (_currentPosition == null) {
        _showErrorDialog('현재 위치를 가져올 수 없습니다.\n위치 권한을 확인해주세요.');
        return;
      }

      // 주차장 데이터 가져오기
      await parkingProvider.fetchParkingLots();

      // 에러가 있어도 정적 데이터를 사용하므로 계속 진행
      if (parkingProvider.error != null) {
        // 조용히 스낵바로 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: '실시간 정보를 불러올 수 없어 저장된 정보를 표시합니다.'.text.make(),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // 거리순으로 정렬된 주차장 목록 가져오기
      final nearbyLots = _getNearbyParkingLots(
        parkingProvider.parkingLots,
        _currentPosition!,
      );

      // 주차장 목록 모달 표시
      _showParkingListModal(nearbyLots, _currentPosition!);
    } catch (e) {
      _showErrorDialog('주차장 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }

  List<Map<String, dynamic>> _getNearbyParkingLots(
    List<ParkingLot> parkingLots,
    Position userPosition,
  ) {
    // 병렬로 거리 계산 (성능 개선)
    final lotsWithDistance = parkingLots.map((lot) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        lot.latitude,
        lot.longitude,
      );
      return {'lot': lot, 'distance': distance};
    }).toList();

    // 거리순으로 정렬 후 상위 20개만 반환 (성능 최적화)
    lotsWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    return lotsWithDistance.length > 20
        ? lotsWithDistance.sublist(0, 20)
        : lotsWithDistance;
  }

  void _showParkingListModal(
    List<Map<String, dynamic>> nearbyLots,
    Position userPosition,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // 핸들
            Row(
              children: [
                spacer,
                Container(
                  width: 36,
                  height: 5,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                spacer,
              ],
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: '내 주변 주차장'.text.bold
                  .size(20.0)
                  .color(Theme.of(context).colorScheme.onPrimaryContainer)
                  .make(),
            ),

            // 주차장 목록
            Expanded(
              child: ListView.builder(
                itemCount: nearbyLots.length,
                itemBuilder: (context, index) {
                  final item = nearbyLots[index];
                  final lot = item['lot'] as ParkingLot;
                  final distance = item['distance'] as double;
                  final distanceText = distance < 1000
                      ? '${distance.round()}m'
                      : '${(distance / 1000).toStringAsFixed(1)}km';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onParkingLotTapped(lot),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: lot.name.text.bold
                                        .size(18.0)
                                        .color(
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        )
                                        .make(),
                                  ),
                                  distanceText.text
                                      .size(14.0)
                                      .color(
                                        Theme.of(context).colorScheme.primary,
                                      )
                                      .bold
                                      .make(),
                                ],
                              ),
                              height5,
                              Row(
                                children: [
                                  '전체: ${lot.totalSpaces}면'.text
                                      .color(
                                        Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                      )
                                      .make(),
                                  width10,
                                  (lot.availableSpaces == -1
                                          ? '총 ${lot.totalSpaces}면'
                                          : '잔여: ${lot.availableSpaces}면')
                                      .text
                                      .color(
                                        lot.availableSpaces == -1
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6)
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      )
                                      .bold
                                      .make(),
                                ],
                              ),
                              height5,
                              lot.address.text
                                  .size(14.0)
                                  .color(
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  )
                                  .make(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onParkingLotTapped(ParkingLot lot) async {
    // 먼저 주변 주차장 목록 모달 닫기
    Navigator.of(context).pop();

    // 홈 페이지로 이동
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }

    // 잠시 대기 후 지도 이동 (화면 전환 완료 후)
    await Future.delayed(const Duration(milliseconds: 300));

    if (_mapController != null) {
      // 지도를 해당 주차장 위치로 이동
      await _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(lot.latitude, lot.longitude),
          zoom: 16,
        ),
      );

      // 잠시 대기 후 주차장 정보 모달 표시
      await Future.delayed(const Duration(milliseconds: 500));
      _showParkingInfoModal(lot);
    }
  }

  void _showParkingInfoModal(ParkingLot lot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Row(
              children: [
                spacer,
                Container(
                  width: 36,
                  height: 5,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                spacer,
              ],
            ),

            // 주차장 이름
            lot.name.text.bold
                .size(24.0)
                .color(Theme.of(context).colorScheme.onPrimaryContainer)
                .make(),
            height10,

            // 주차 현황
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      '전체 주차면'.text
                          .color(
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          )
                          .size(14)
                          .make(),
                      height5,
                      '${lot.totalSpaces}면'.text
                          .color(Theme.of(context).colorScheme.onSurface)
                          .size(20)
                          .bold
                          .make(),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      '잔여 주차면'.text
                          .color(
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          )
                          .size(14)
                          .make(),
                      height5,
                      (lot.availableSpaces == -1
                              ? '총 ${lot.totalSpaces}면'
                              : '${lot.availableSpaces}면')
                          .text
                          .color(
                            lot.availableSpaces == -1
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)
                                : lot.availableSpaces > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                          )
                          .size(20)
                          .bold
                          .make(),
                    ],
                  ),
                ],
              ),
            ),
            height10,

            // 주소
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
                width5,
                Expanded(
                  child: lot.address.text
                      .color(
                        Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      )
                      .size(15)
                      .make(),
                ),
              ],
            ),
            height10,

            // 버튼들
            Row(
              children: [
                // 길찾기 버튼
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchNavigation(lot),
                    icon: const Icon(Icons.directions, size: 18),
                    label: '길찾기'.text.size(14).bold.make(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                width10,
                // 공유 버튼
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareParking(lot),
                    icon: const Icon(Icons.share, size: 18),
                    label: '공유'.text.size(14).bold.make(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareParking(ParkingLot lot) async {
    final shareText =
        '''
🅿️ ${lot.name}

📍 주소: ${lot.address}

🚗 주차 현황:
  • 전체 ${lot.totalSpaces}면${lot.availableSpaces == -1 ? '\n  ⚠️ 실시간 정보 없음' : '\n  • 잔여 ${lot.availableSpaces}면\n  ${lot.availableSpaces == 0 ? '⚠️ 주차 불가' : '✅ 주차 가능'}'}

📱 대자 앱으로 실시간 주차 정보를 확인하세요!

🗺️ 위치: https://map.naver.com/v5/search/${Uri.encodeComponent(lot.name)}
    ''';

    try {
      await Share.share(shareText, subject: '🅿️ ${lot.name} 주차장 정보');
    } catch (e) {
      _showErrorDialog('공유하는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _launchNavigation(ParkingLot lot) async {
    if (_currentPosition == null) {
      _showErrorDialog('현재 위치를 가져올 수 없습니다');
      return;
    }

    try {
      await LaunchMapHelper.launchNavigation(
        context: context,
        originLatitude: _currentPosition!.latitude,
        originLongitude: _currentPosition!.longitude,
        destinationLatitude: lot.latitude,
        destinationLongitude: lot.longitude,
        destinationTitle: lot.name,
      );
    } catch (e) {
      _showErrorDialog('지도 앱을 실행할 수 없습니다');
    }
  }

  void _showErrorDialog(String message) {
    Dialogs.showErrorDialog(context, message);
  }

  // 위치 권한 설정 안내 다이얼로그
  void _showPermissionSettingsDialog() {
    Dialogs.showSettingsDialog(
      context,
      '위치 권한 필요',
      '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.',
    );
  }

  // 위치 서비스 활성화 안내 다이얼로그
  void _showLocationServiceDialog() {
    Dialogs.showSettingsDialog(
      context,
      '위치 서비스 필요',
      '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNearbyParkingLots(),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/icons/parked-car.png',
            color: Theme.of(context).colorScheme.onPrimary,
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
