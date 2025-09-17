import 'dart:async';
import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/providers/parking_provider.dart';
import 'package:daeja/widgets/map_controller.dart';
import 'package:daeja/widgets/parking_marker.dart';
import 'package:daeja/widgets/cluster_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../helper/location_service.dart';
import '../models/parking_lot.dart';
import '../utils/marker_clustering.dart';

class HomePage extends StatefulWidget {
  final Function(NaverMapController)? onMapControllerReady;
  
  const HomePage({super.key, this.onMapControllerReady});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NaverMapController? mapController;
  Timer? _debounceTimer;
  List<ParkingLot> _currentParkingLots = [];

  @override
  void dispose() {
    // 메모리 최적화: 마커 캐시 정리
    clearMarkerCache();
    clearClusterMarkerCache();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _updateMarkersDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (mapController != null && _currentParkingLots.isNotEmpty) {
        final cameraPosition = await mapController!.getCameraPosition();
        await _updateMarkers(mapController!, cameraPosition.zoom, _currentParkingLots);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position?>(
      future: LocationHelper.getPosition().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      ),
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
        // 제주도 중심 좌표 (위치를 가져올 수 없는 경우)
        final location = NLatLng(
          pos?.latitude ?? 33.4996,
          pos?.longitude ?? 126.5312,
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
              onCameraChange: (NCameraUpdateReason reason, bool isAnimated) {
                // 카메라 변경 시 클러스터링 업데이트
                if (mapController != null) {
                  _updateMarkersDebounced();
                }
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

    // 현재 주차장 목록 저장
    _currentParkingLots = parkingProvider.parkingLots;
    
    // 초기 줌 레벨로 클러스터링 적용
    await _updateMarkers(controller, 14.0, _currentParkingLots);
  }
  
  Future<void> _updateMarkers(NaverMapController controller, double zoomLevel, List<ParkingLot> lots) async {
    // 기존 마커들 제거
    await controller.clearOverlays(type: NOverlayType.marker);
    
    // 클러스터링 적용
    final clusters = MarkerClustering.clusterParkingLots(lots, zoomLevel);
    
    // 병렬로 클러스터 마커 생성
    final markerFutures = clusters.map((cluster) => buildClusterMarker(cluster, context));
    final markerIcons = await Future.wait(markerFutures);
    
    // 마커 추가
    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      final markerIcon = markerIcons[i];
      
      final marker = NMarker(
        id: cluster.isCluster ? 'cluster_$i' : cluster.parkingLots.first.id,
        position: NLatLng(cluster.latitude, cluster.longitude),
        icon: markerIcon,
      );

      marker.setOnTapListener((overlay) {
        if (cluster.isCluster) {
          _showClusterInfoModal(cluster);
        } else {
          _showParkingInfoModal(cluster.parkingLots.first);
        }
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
            
            // 버튼들
            Row(
              children: [
                // 길찾기 버튼
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _openNaverMap(lot),
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
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
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

  void _showClusterInfoModal(ClusterPoint cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            
            // 클러스터 정보
            '이 지역 주차장 ${cluster.size}곳'.text.bold
                .size(20.0)
                .color(Theme.of(context).colorScheme.onPrimaryContainer)
                .make(),
            height10,
            
            // 전체 주차 현황
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      '전체 주차면'.text
                          .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
                          .size(14)
                          .make(),
                      height5,
                      '${cluster.totalSpaces}면'.text
                          .color(Theme.of(context).colorScheme.onSurface)
                          .size(18)
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
                    children: [
                      '잔여 주차면'.text
                          .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
                          .size(14)
                          .make(),
                      height5,
                      '${cluster.totalAvailableSpaces}면'.text
                          .color(cluster.totalAvailableSpaces > 0 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.error)
                          .size(18)
                          .bold
                          .make(),
                    ],
                  ),
                ],
              ),
            ),
            
            // 주차장 목록
            Expanded(
              child: ListView.builder(
                itemCount: cluster.parkingLots.length,
                itemBuilder: (context, index) {
                  final lot = cluster.parkingLots[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: lot.name.text.bold
                          .size(16.0)
                          .color(Theme.of(context).colorScheme.onSurface)
                          .make(),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height5,
                          Row(
                            children: [
                              '전체: ${lot.totalSpaces}면'.text
                                  .color(Theme.of(context).colorScheme.onSurface.withOpacity(0.7))
                                  .size(12)
                                  .make(),
                              width10,
                              '잔여: ${lot.availableSpaces}면'.text
                                  .color(lot.availableSpaces > 0 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.error)
                                  .size(12)
                                  .bold
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showParkingInfoModal(lot);
                      },
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

  Future<void> _shareParking(ParkingLot lot) async {
    final shareText = '''
🅿️ ${lot.name}

📍 주소: ${lot.address}

🚗 주차 현황:
  • 전체 ${lot.totalSpaces}면
  • 잔여 ${lot.availableSpaces}면
  ${lot.availableSpaces == 0 ? '⚠️ 주차 불가' : '✅ 주차 가능'}

📱 대제주 앱으로 실시간 주차 정보를 확인하세요!

🗺️ 위치: https://map.naver.com/v5/search/${Uri.encodeComponent(lot.name)}
    ''';

    try {
      await Share.share(
        shareText,
        subject: '🅿️ ${lot.name} 주차장 정보',
      );
    } catch (e) {
      _showErrorDialog('공유하는 중 오류가 발생했습니다.');
    }
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