import 'package:daeja/constants/constants.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_state.dart';
import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/presentation/widget/sheet/badge/time_badge.dart';
import 'package:daeja/presentation/widget/sheet/navigation_selection_sheet.dart';
import 'package:daeja/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:daeja/utils/share_parking_lot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParkingDetailSheet extends StatelessWidget {
  final ParkingLot parking;
  final DateTime? lastUpdated;

  const ParkingDetailSheet({
    super.key,
    required this.parking,
    this.lastUpdated,
  });

  static void show(BuildContext context, ParkingLot parking) {
    final state = context.read<ParkingLotCubit>().state;
    final lastUpdated = state is ParkingLotResult ? state.lastUpdated : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          ParkingDetailSheet(parking: parking, lastUpdated: lastUpdated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: sheetPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: sheetBorderRadius,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHandleBar(),
          _buildHeader(context),
          SizedBox(height: 10.0),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 주차장 이름
        Expanded(
          child: Text(
            parking.name.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          ),
        ),

        SizedBox(width: 10.0),

        if (lastUpdated != null) TimeBadge(lastUpdated: lastUpdated!),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주차 현환
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              // 전체 주차면
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 전체 주차면
                  Text(
                    '전체 주차면',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14.0,
                    ),
                  ),

                  SizedBox(height: 5.0),

                  Text(
                    '${parking.wholNpls}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),

              // 잔여 주차면
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 전체 주차면
                  Text(
                    '잔여 주차면',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14.0,
                    ),
                  ),

                  SizedBox(height: 5.0),

                  // 잔여 주차면
                  Text(
                    '${parking.gnrl}',
                    style: TextStyle(
                      color: parking.gnrl == 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 10.0),

        // 주소
        Row(
          children: [
            // 주소 Icon
            Icon(
              Icons.location_on,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),

            SizedBox(width: 5.0),

            // 주소 Text
            Expanded(
              child: Text(
                parking.addr.toString(),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0),

        // 버튼들
        Row(
          children: [
            // 길찾기 버튼
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationSelectionSheet.show(context, parking);
                },
                icon: Icon(Icons.directions, size: 18.0),
                label: Text(
                  '길찾기',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            SizedBox(width: 10.0),

            // 공유 버튼
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  ShareParkingLot.shareParkingInfo(parking);
                },
                icon: Icon(Icons.share, size: 18.0),
                label: Text(
                  '공유',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
