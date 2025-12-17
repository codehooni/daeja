import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/parking/domain/models/parking_lot.dart';
import '../features/parking/presentation/providers/parking_providers.dart';
import '../past/presentation/widget/map/zoom_buttons.dart';

class ParkingMapScreen extends ConsumerStatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  ConsumerState<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends ConsumerState<ParkingMapScreen> {
  NaverMapController? _mapController;
  final List<NMarker> _markers = [];
  ParkingLot? _selectedParkingLot;

  @override
  void dispose() {
    _clearMarkers();
    super.dispose();
  }

  Future<void> _clearMarkers() async {
    if (_mapController == null) return;
    for (final marker in _markers) {
      await _mapController!.deleteOverlay(marker.info);
    }
    _markers.clear();
  }

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;

    // 제주공항으로 초기 위치 설정
    await controller.updateCamera(
      NCameraUpdate.fromCameraPosition(
        const NCameraPosition(target: NLatLng(33.5066, 126.4933), zoom: 13),
      ),
    );

    // 주차장 마커 로드
    final parkingLotsAsync = ref.read(parkingLotsProvider);
    parkingLotsAsync.whenData((parkingLots) {
      _loadMarkers(parkingLots);
    });
  }

  Future<void> _loadMarkers(List<ParkingLot> parkingLots) async {
    if (_mapController == null || !mounted) return;

    // 기존 마커 제거
    await _clearMarkers();

    if (!mounted) return;

    // 새 마커 추가
    for (final parkingLot in parkingLots) {
      if (!mounted) return;

      // 사용 가능률에 따라 색상 결정
      final availabilityRate = parkingLot.totalSpots > 0
          ? (parkingLot.availableSpots / parkingLot.totalSpots)
          : 0.0;

      Color markerColor;
      if (availabilityRate >= 0.5) {
        markerColor = Colors.green;
      } else if (availabilityRate >= 0.2) {
        markerColor = Colors.orange;
      } else if (availabilityRate > 0) {
        markerColor = Colors.red;
      } else {
        markerColor = Colors.grey;
      }

      // 마커 아이콘 설정
      final icon = await NOverlayImage.fromWidget(
        widget: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Center(
            child: Icon(Icons.local_parking, color: Colors.white, size: 24),
          ),
        ),
        size: const Size(40, 40),
        context: context,
      );

      if (!mounted) return;

      final marker = NMarker(
        id: parkingLot.id,
        position: NLatLng(parkingLot.lat, parkingLot.lng),
        icon: icon,
      );

      // 마커 캡션 설정
      marker.setCaption(NOverlayCaption(text: parkingLot.name, textSize: 12));

      // 마커 탭 이벤트
      marker.setOnTapListener((overlay) {
        if (mounted) {
          setState(() {
            _selectedParkingLot = parkingLot;
          });
        }
      });

      await _mapController!.addOverlay(marker);
      _markers.add(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotsAsync = ref.watch(parkingLotsProvider);

    return parkingLotsAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('주차장 정보를 불러오는 중...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('에러: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(parkingLotsProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (parkingLots) {
        return Stack(
          children: [
            // 네이버 맵
            NaverMap(
              options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(33.5066, 126.4933),
                  zoom: 13,
                ),
                locationButtonEnable: false,
                mapType: NMapType.basic,
                scrollGesturesEnable: true,
                zoomGesturesEnable: true,
                tiltGesturesEnable: true,
                rotationGesturesEnable: true,
              ),
              onMapReady: _onMapReady,
            ),

            // 주차장 정보 카드
            if (_selectedParkingLot != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildParkingInfoCard(_selectedParkingLot!),
              ),

            // 범례
            Positioned(top: 16, right: 16, child: _buildLegend()),

            // 새로고침 버튼
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'refresh',
                onPressed: () {
                  ref.invalidate(parkingLotsProvider);
                },
                child: const Icon(Icons.refresh),
              ),
            ),

            // 줌 버튼
            Positioned(
              bottom: _selectedParkingLot != null ? 290 : 90,
              right: 16,
              child: ZoomButtons(mapController: _mapController),
            ),

            // 내 위치 버튼
            Positioned(
              bottom: _selectedParkingLot != null ? 220 : 16,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'location',
                onPressed: () async {
                  if (_mapController != null) {
                    await _mapController!.updateCamera(
                      NCameraUpdate.fromCameraPosition(
                        const NCameraPosition(
                          target: NLatLng(33.5066, 126.4933),
                          zoom: 13,
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '주차 가능',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.green, '여유 (50% 이상)'),
            _buildLegendItem(Colors.orange, '보통 (20-50%)'),
            _buildLegendItem(Colors.red, '혼잡 (20% 미만)'),
            _buildLegendItem(Colors.grey, '만차'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildParkingInfoCard(ParkingLot parkingLot) {
    final availabilityRate = parkingLot.totalSpots > 0
        ? (parkingLot.availableSpots / parkingLot.totalSpots * 100)
        : 0.0;

    Color statusColor;
    String statusText;

    if (availabilityRate >= 50) {
      statusColor = Colors.green;
      statusText = '여유';
    } else if (availabilityRate >= 20) {
      statusColor = Colors.orange;
      statusText = '보통';
    } else if (availabilityRate > 0) {
      statusColor = Colors.red;
      statusText = '혼잡';
    } else {
      statusColor = Colors.grey;
      statusText = '만차';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parkingLot.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parkingLot.address,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedParkingLot = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  '총 주차면',
                  '${parkingLot.totalSpots}면',
                  Icons.local_parking,
                ),
                _buildInfoColumn(
                  '사용 가능',
                  '${parkingLot.availableSpots}면',
                  Icons.check_circle,
                ),
                if (parkingLot.fee != null)
                  _buildInfoColumn(
                    '요금',
                    '${parkingLot.fee}원',
                    Icons.attach_money,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '사용 가능률',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${availabilityRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: availabilityRate / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
