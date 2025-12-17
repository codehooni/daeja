import 'dart:math';

import 'package:daeja/past/constants/constants.dart';
import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:daeja/past/feature/user_location/provider/user_location_provider.dart';
import 'package:daeja/main.dart';
import 'package:daeja/past/presentation/widget/sheet/badge/valet_badge.dart';
import 'package:daeja/past/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feature/parking/provider/parking_provider.dart';

class ParkingListSheet extends ConsumerWidget {
  final Function(ParkingLot)? onParkingTap;

  const ParkingListSheet({super.key, this.onParkingTap});

  static void show(
    BuildContext context, {
    Function(ParkingLot)? onParkingTap,
    WidgetRef? ref,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ParkingListSheet(onParkingTap: onParkingTap),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: mq.height * 0.7,
      padding: sheetPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: sheetBorderRadius,
      ),

      child: Column(
        children: [
          SheetHandleBar(),
          _buildHeader(context),
          Expanded(child: _buildContent(context, ref)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        '내 주변 주차장',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final userPosition = ref.watch(userLocationProvider).asData?.value;
    final parkingDataAsync = ref.watch(parkingLotProvider);

    return parkingDataAsync.when(
      data: (parkingData) {
        // 위치 로딩중
        if (userPosition == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (parkingData.isEmpty) {
          return const Center(child: Text('데이터가 없습니다.'));
        }

        final parkingLots = parkingData;

        // 주차장 정보 없음
        if (parkingLots.isEmpty) {
          return Center(
            child: Text(
              '주차장 정보가 없습니다',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          );
        }

        final sortedLots = List<ParkingLot>.from(parkingLots);
        sortedLots.sort((a, b) {
          final distanceA = _calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            double.parse(a.yCrdn.toString()),
            double.parse(a.xCrdn.toString()),
          );
          final distanceB = _calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            double.parse(b.yCrdn.toString()),
            double.parse(b.xCrdn.toString()),
          );
          return distanceA.compareTo(distanceB);
        });

        return ListView.builder(
          itemCount: sortedLots.length,
          itemBuilder: (context, index) {
            final parking = sortedLots[index];
            return _buildParkingItem(context, parking);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다.\n$err')),
    );
  }

  // 거리 계산
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Widget _buildParkingItem(BuildContext context, ParkingLot parking) {
    final isValetParking = parking.parkingType == 'valet';

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            Navigator.pop(context);
            onParkingTap?.call(parking);
          },
          child: Padding(
            padding: EdgeInsetsGeometry.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 주차장 이름
                Row(
                  children: [
                    if (isValetParking) ...[
                      const ValetBadge(),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        parking.name.toString(),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5.0),

                // 주차면수
                Row(
                  children: [
                    // 전체 주차면수
                    Text(
                      '전체: ${parking.wholNpls}면',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    SizedBox(width: 10.0),

                    // 잔여 주차면수
                    Text(
                      '잔여: ${parking.totalRemaining}면',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5.0),

                // 주소
                Text(
                  '${parking.addr}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
