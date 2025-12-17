import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/parking/domain/models/parking_lot.dart';
import '../features/parking/presentation/providers/parking_providers.dart';

class ParkingTestScreen extends ConsumerWidget {
  const ParkingTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parkingLotsAsync = ref.watch(parkingLotsProvider);

    return parkingLotsAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('주차장 정보 불러오는 중...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '주차장 정보를 불러오는데 실패했습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(parkingLotsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (parkingLots) {
        if (parkingLots.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_parking, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('주차장 정보가 없습니다', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 요약 정보
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    '총 주차장',
                    '${parkingLots.length}개',
                    Icons.local_parking,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    '총 주차면',
                    '${parkingLots.fold<int>(0, (sum, lot) => sum + lot.totalSpots)}면',
                    Icons.grid_view,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    '사용 가능',
                    '${parkingLots.fold<int>(0, (sum, lot) => sum + lot.availableSpots)}면',
                    Icons.check_circle,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 주차장 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: parkingLots.length,
                itemBuilder: (context, index) {
                  final parkingLot = parkingLots[index];
                  return _buildParkingLotCard(parkingLot);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildParkingLotCard(ParkingLot parkingLot) {
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on,
                    '위치',
                    '${parkingLot.lat.toStringAsFixed(4)}, ${parkingLot.lng.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.local_parking,
                    '총 주차면',
                    '${parkingLot.totalSpots}면',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.check_circle_outline,
                    '사용 가능',
                    '${parkingLot.availableSpots}면',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (parkingLot.fee != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      '요금',
                      '${parkingLot.fee}원',
                    ),
                  ),
                if (parkingLot.distance != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.directions_walk,
                      '거리',
                      '${(parkingLot.distance! / 1000).toStringAsFixed(2)}km',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 사용률 프로그레스바
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
