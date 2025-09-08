import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/providers/parking_provider.dart';
import 'package:daeja/widgets/map_controller.dart';
import 'package:daeja/widgets/parking_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/location_service.dart';
import '../models/parking_lot.dart';

class HomePage extends StatefulWidget {
  final Function(NaverMapController)? onMapControllerReady;
  
  const HomePage({super.key, this.onMapControllerReady});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NaverMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position?>(
      future: LocationHelper.getPosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '지도를 준비하는 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final pos = snapshot.data;
        final location = NLatLng(
          pos?.latitude ?? 37.5666,
          pos?.longitude ?? 126.979,
        );

        return Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: location,
                  zoom: 14,
                ),
              ),
              onMapReady: (controller) {
                mapController = controller;
                onMapReady(controller);
                widget.onMapControllerReady?.call(controller);
              },
            ),


            Positioned(
              right: 4,
              bottom: 120,
              child: Column(
                children: [
                  MapController(
                    icon: Icons.add,
                    onTap: () =>
                        mapController?.updateCamera(NCameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 10),
                  MapController(
                    icon: Icons.remove,
                    onTap: () =>
                        mapController?.updateCamera(NCameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 10),
                  MapController(
                    icon: Icons.my_location,
                    onTap: () => _moveToMyLocation(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onMapReady(NaverMapController controller) async {
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    
    // Provider에서 주차장 데이터 가져오기
    await parkingProvider.fetchParkingLots();
    
    if (parkingProvider.error != null) {
      _showErrorDialog(parkingProvider.error!);
      return;
    }

    final lots = parkingProvider.parkingLots;
    for (var lot in lots) {
      final markerIcon = await buildParkingMarker(lot, context);
      final marker = NMarker(
        id: lot.id,
        position: NLatLng(lot.latitude, lot.longitude),
        icon: markerIcon,
      );

      marker.setOnTapListener((overlay) {
        _showParkingInfoModal(lot);
      });

      controller.addOverlay(marker);
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
                          .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
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
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      '잔여 주차면'.text
                          .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
                          .size(14)
                          .make(),
                      height5,
                      '${lot.availableSpaces}면'.text
                          .color(lot.availableSpaces > 0 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.error)
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
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
                width5,
                Expanded(
                  child: lot.address.text
                      .color(Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8))
                      .size(15)
                      .make(),
                ),
              ],
            ),
            height10,
            
            // 길찾기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openNaverMap(lot),
                icon: const Icon(Icons.directions, size: 20),
                label: '네이버맵에서 길찾기'.text.size(16).bold.make(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNaverMap(ParkingLot lot) async {
    // 네이버맵 딥링크 URL 생성
    final url = Uri.parse(
      'nmap://place?lat=${lot.latitude}&lng=${lot.longitude}&name=${Uri.encodeComponent(lot.name)}&appname=daeja'
    );
    
    // 네이버맵 웹 URL (앱이 설치되지 않은 경우)
    final webUrl = Uri.parse(
      'https://map.naver.com/v5/search/${Uri.encodeComponent(lot.name)}'
    );

    try {
      // 네이버맵 앱으로 열기 시도
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // 앱이 없으면 웹으로 열기
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showErrorDialog('네이버맵을 열 수 없습니다.');
    }
  }

  // 에러 다이얼로그 표시 함수
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

  // 내 위치로 이동하기 (카메라만 이동)
  Future<void> _moveToMyLocation() async {
    try {
      final position = await LocationHelper.getPosition();
      if (position == null) {
        _showErrorDialog('현재 위치를 가져올 수 없습니다.');
        return;
      }

      // 지도를 현재 위치로 이동
      if (mapController != null) {
        await mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('위치 이동 중 오류가 발생했습니다.');
    }
  }
}