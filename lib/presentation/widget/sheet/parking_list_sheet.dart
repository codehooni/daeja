import 'package:daeja/constants/constants.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_state.dart';
import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/main.dart';
import 'package:daeja/presentation/widget/sheet/parking_detail_sheet.dart';
import 'package:daeja/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParkingListSheet extends StatelessWidget {
  const ParkingListSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ParkingListSheet(),
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

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<ParkingLotCubit, ParkingLotState>(
      builder: (context, state) {
        if (state is ParkingLotLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is ParkingLotResult) {
          return ListView.builder(
            itemCount: state.parkingLots.length,
            itemBuilder: (context, index) {
              final parking = state.parkingLots[index];
              return _buildParkingItem(context, parking);
            },
          );
        }

        if (state is ParkingLotInitial) {
          return ListView.builder(
            itemCount: state.parkingLots.length,
            itemBuilder: (context, index) {
              final parking = state.parkingLots[index];
              return _buildParkingItem(context, parking);
            },
          );
        }

        // 주차장 정보 없음
        return Center(
          child: Text(
            '주차장 정보가 없습니다',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        );
      },
    );
  }
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
          ParkingDetailSheet.show(context, parking);
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
                    '전체: ${parking.gnrl}면',
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
