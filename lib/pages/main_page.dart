import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../widgets/my_bottom_navigation_item.dart';
import '../providers/parking_provider.dart';
import '../helper/location_service.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onMapControllerReady: (controller) {
        _mapController = controller;
      }),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _showNearbyParkingLots() async {
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    
    try {
      // 현재 위치 가져오기
      final position = await LocationHelper.getPosition();
      if (position == null) {
        _showErrorDialog('현재 위치를 가져올 수 없습니다.');
        return;
      }

      // 주차장 데이터 가져오기
      await parkingProvider.fetchParkingLots();
      
      if (parkingProvider.error != null) {
        _showErrorDialog(parkingProvider.error!);
        return;
      }

      // 거리순으로 정렬된 주차장 목록 가져오기
      final nearbyLots = _getNearbyParkingLots(
        parkingProvider.parkingLots,
        position,
      );

      // 주차장 목록 모달 표시
      _showParkingListModal(nearbyLots, position);

    } catch (e) {
      _showErrorDialog('주차장 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }

  List<Map<String, dynamic>> _getNearbyParkingLots(
    List<ParkingLot> parkingLots,
    Position userPosition,
  ) {
    final lotsWithDistance = parkingLots.map((lot) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        lot.latitude,
        lot.longitude,
      );
      return {
        'lot': lot,
        'distance': distance,
      };
    }).toList();

    // 거리순으로 정렬
    lotsWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    return lotsWithDistance;
  }

  void _showParkingListModal(List<Map<String, dynamic>> nearbyLots, Position userPosition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(
          top: 4,
          left: 16,
          right: 16,
          bottom: 48,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
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

                  return GestureDetector(
                    onTap: () => _onParkingLotTapped(lot),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            Expanded(
                              child: lot.name.text.bold
                                  .size(18.0)
                                  .color(Theme.of(context).colorScheme.onSurface)
                                  .make(),
                            ),
                            distanceText.text
                                .size(14.0)
                                .color(Theme.of(context).colorScheme.primary)
                                .bold
                                .make(),
                          ],
                        ),
                        height5,
                        Row(
                          children: [
                            '전체: ${lot.totalSpaces}면'.text
                                .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
                                .make(),
                            width10,
                            '잔여: ${lot.availableSpaces}면'.text
                                .color(Theme.of(context).colorScheme.primary)
                                .bold
                                .make(),
                          ],
                        ),
                        height5,
                        lot.address.text
                            .size(14.0)
                            .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.6))
                            .make(),
                      ],
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
        padding: const EdgeInsets.only(
          top: 4,
          left: 16,
          right: 16,
          bottom: 48,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                lot.name.text.bold
                    .size(22.0)
                    .color(Theme.of(context).colorScheme.onPrimaryContainer)
                    .make(),
                width10,
                '전체: ${lot.totalSpaces}'.text.make(),
              ],
            ),
            height5,
            '잔여: ${lot.availableSpaces}면'.text
                .color(Theme.of(context).colorScheme.primary)
                .bold
                .make(),
            height10,
            lot.address.text.make(),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: '오류'.text.bold.make(),
        content: message.text.make(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: '확인'.text.make(),
          ),
        ],
      ),
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
            // MyBottomNavigationItem(
            //   isMe: _currentIndex == 1,
            //   icon: Icons.search,
            //   onPressed: () => _onItemTapped(1),
            // ),
            SizedBox(),
            // MyBottomNavigationItem(
            //   isMe: _currentIndex == 2,
            //   icon: Icons.history,
            //   onPressed: () => _onItemTapped(2),
            // ),
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
        child: 'P'.text
            .size(32)
            .bold
            .color(Theme.of(context).colorScheme.onPrimary)
            .make(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}