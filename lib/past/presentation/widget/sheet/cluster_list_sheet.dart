import 'package:daeja/past/constants/constants.dart';
import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:daeja/past/presentation/widget/sheet/badge/valet_badge.dart';
import 'package:daeja/past/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:flutter/material.dart';

import '../../../feature/parking/model/parking_cluster.dart';

class ClusterListSheet extends StatelessWidget {
  final ParkingCluster cluster;
  final Function(ParkingLot)? onParkingTap;

  const ClusterListSheet({super.key, required this.cluster, this.onParkingTap});

  static void show(
    BuildContext context,
    ParkingCluster cluster, {
    Function(ParkingLot)? onParkingTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ClusterListSheet(cluster: cluster, onParkingTap: onParkingTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: sheetPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: sheetBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHandleBar(),
          _buildHeader(context),
          const SizedBox(height: 16),
          Flexible(child: _buildParkingList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            '주차장 ${cluster.count}곳',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '총 ${cluster.totalRemaining}면 여유',
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cluster.parkingLots.length,
      itemBuilder: (context, index) {
        final parking = cluster.parkingLots[index];
        return _buildParkingItem(context, parking);
      },
    );
  }

  Widget _buildParkingItem(BuildContext context, ParkingLot parking) {
    final isValetParking = parking.parkingType == 'valet';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            Navigator.pop(context); // 리스트 시트 닫기
            onParkingTap?.call(parking); // 주차장 선택 콜백 호출
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5.0),

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

                    const SizedBox(width: 10.0),

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

                const SizedBox(height: 5.0),

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
