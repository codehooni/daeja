import 'dart:math';

import 'package:daeja/constants/constants.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_state.dart';
import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/main.dart';
import 'package:daeja/presentation/widget/sheet/badge/time_badge.dart';
import 'package:daeja/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParkingListSheet extends StatelessWidget {
  final Function(ParkingLot)? onParkingTap;
  final DateTime? lastUpdated;

  const ParkingListSheet({super.key, this.onParkingTap, this.lastUpdated});

  static void show(BuildContext context, {Function(ParkingLot)? onParkingTap}) {
    final state = context.read<ParkingLotCubit>().state;
    final lastUpdated = state is ParkingLotResult ? state.lastUpdated : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ParkingListSheet(
        onParkingTap: onParkingTap,
        lastUpdated: lastUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),

          Text(
            '내 주변 주차장',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),

          Expanded(
            child: lastUpdated != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: TimeBadge(lastUpdated: lastUpdated!),
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final userPosition = context.watch<UserLocationProvider>().currentPosition;

    return BlocBuilder<ParkingLotCubit, ParkingLotState>(
      builder: (context, state) {
        // 로딩중
        if (state is ParkingLotLoading) {
          return Center(child: CircularProgressIndicator());
        }

        List<ParkingLot> parkingLots = [];

        if (state is ParkingLotResult) {
          parkingLots = state.parkingLots;
        } else if (state is ParkingLotInitial) {
          parkingLots = state.parkingLots;
        }

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
                Text(
                  parking.name.toString(),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
