import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/providers/parking_provider.dart';
import 'package:daeja/widgets/map_controller.dart';
import 'package:daeja/widgets/parking_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../helper/location_service.dart';

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
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
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
      });

      controller.addOverlay(marker);
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