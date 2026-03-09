import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../domain/models/parking_lot.dart';
import '../navigation_selection_sheet.dart';

class GeneralParkingSheet extends StatelessWidget {
  final ParkingLot parkingLot;

  const GeneralParkingSheet({super.key, required this.parkingLot});

  static void show(BuildContext context, ParkingLot parkingLot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GeneralParkingSheet(parkingLot: parkingLot),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

    return VStack([
          // 드래그 핸들
          VxBox()
              .width(40)
              .height(4)
              .gray300
              .roundedSM
              .make()
              .centered()
              .pSymmetric(v: 12),

          // 컨텐츠
          VStack([
            HStack([
              // 주차장 이름
              parkingLot.name.text.size(18).bold.make(),
              8.widthBox,

              // 주차장 타입
              _buildTypeChip(parkingLot.type),
            ]),
            16.heightBox,

            // 잔여 면수
            _buildAvailabilityStatus(),
            12.heightBox,

            // 주소
            HStack([
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              8.widthBox,
              parkingLot.address.text.size(14).gray600.make().expand(),
            ], crossAlignment: CrossAxisAlignment.start),
            12.heightBox,

            // 요금 정보
            if (parkingLot.basePrice != null &&
                parkingLot.unitTime != null &&
                parkingLot.unitPrice != null) ...[
              _buildPricingInfo(),
              12.heightBox,
            ] else if (parkingLot.fee != null) ...[
              HStack([
                const Icon(Icons.payments, size: 20, color: Colors.grey),
                8.widthBox,
                '${parkingLot.fee}원'.text.size(14).gray600.make(),
              ]),
              12.heightBox,
            ],

            // 거리 정보
            if (parkingLot.distance != null) ...[
              HStack([
                const Icon(Icons.directions_walk, size: 20, color: Colors.grey),
                8.widthBox,
                '${(parkingLot.distance! / 1000).toStringAsFixed(1)}km'.text
                    .size(14)
                    .gray600
                    .make(),
              ]),
              12.heightBox,
            ],

            8.heightBox,

            // 버튼 영역

            // 일반 주차장: 길찾기만
            HStack([
                  Icon(Icons.navigation, color: Colors.white, size: 20),
                  8.widthBox,
                  '길찾기'.text.white.bold.size(16).make(),
                ])
                .centered()
                .p16()
                .box
                .blue600
                .roundedLg
                .make()
                .onInkTap(() => _openNavigation(context))
                .wFull(context),

            4.heightBox,
            mq.padding.bottom.heightBox,
          ], crossAlignment: CrossAxisAlignment.start).pSymmetric(h: 20),
        ], crossAlignment: CrossAxisAlignment.stretch).box.white
        .customRounded(
          const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        )
        .make();
  }

  /// 이용가능 대수에 따른 상태 위젯
  Widget _buildAvailabilityStatus() {
    final available = parkingLot.availableSpots;
    final total = parkingLot.totalSpots;

    // 상태에 따른 설정
    String statusText;
    Color statusColor;
    Color bgColor;
    IconData icon;

    if (available == 0) {
      // 만차
      statusText = '만차';
      statusColor = Colors.red;
      bgColor = Colors.red.shade50;
      icon = Icons.cancel_outlined;
    } else if (available <= 5) {
      // 곧 만차
      statusText = '곧 만차';
      statusColor = Colors.orange;
      bgColor = Colors.orange.shade50;
      icon = Icons.warning_outlined;
    } else {
      // 주차 가능
      statusText = '주차가능';
      statusColor = Colors.green;
      bgColor = Colors.green.shade50;
      icon = Icons.check_circle_outlined;
    }

    return HStack([
          Icon(icon, color: statusColor, size: 20),
          4.widthBox,
          statusText.text.color(statusColor).size(16).bold.make(),

          Spacer(),
          '이용가능 $available대 / 총 $total대'.text
              .size(14)
              .color(statusColor)
              .fontWeight(FontWeight.w500)
              .make(),
        ], crossAlignment: CrossAxisAlignment.center)
        .pSymmetric(v: 12, h: 12)
        .box
        .roundedSM
        .color(bgColor)
        .make();
  }

  /// 주차장 타입 칩 위젯
  Widget _buildTypeChip(ParkingLotType type) {
    String label;
    Color color;

    switch (type) {
      case ParkingLotType.valet:
        label = '발렛';
        color = const Color(0xFF7808FF);
        break;
      case ParkingLotType.private:
        label = '민영';
        color = Color(0xFFFF7207);
        break;
      case ParkingLotType.public:
        label = '공영';
        color = Color(0xFF0059FF);
        break;
    }

    return label.text
        .size(12)
        .bold
        .color(Colors.white)
        .make()
        .pSymmetric(h: 8, v: 4)
        .box
        .color(color)
        .roundedSM
        .make();
  }

  /// 분을 적절한 시간 단위로 포맷팅
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours시간';
      } else {
        return '$hours시간 $remainingMinutes분';
      }
    } else {
      final days = minutes ~/ 1440;
      final remainingHours = (minutes % 1440) ~/ 60;
      if (remainingHours == 0) {
        return '$days일';
      } else {
        return '$days일 $remainingHours시간';
      }
    }
  }

  /// 요금 정보 위젯 (상세)
  Widget _buildPricingInfo() {
    final basePrice = parkingLot.basePrice!;
    final unitTime = parkingLot.unitTime!;
    final unitPrice = parkingLot.unitPrice!;
    final isValet = parkingLot.type == ParkingLotType.valet;

    // 발렛 주차는 날짜 기반, 일반 주차는 시간 기반 계산
    late final int? fee1, fee2, fee3;
    late final String label1, label2, label3;

    if (isValet) {
      // 발렛: 날짜 기반 계산 (당일부터 카운트)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final day1Exit = today.add(
        const Duration(days: 0, hours: 23, minutes: 59),
      );
      final day2Exit = today.add(
        const Duration(days: 1, hours: 23, minutes: 59),
      );
      final day3Exit = today.add(
        const Duration(days: 2, hours: 23, minutes: 59),
      );

      fee1 = parkingLot.calculateFeeByDate(today, day1Exit);
      fee2 = parkingLot.calculateFeeByDate(today, day2Exit);
      fee3 = parkingLot.calculateFeeByDate(today, day3Exit);

      label1 = '1일';
      label2 = '2일';
      label3 = '3일';
    } else {
      // 일반 주차: 시간 기반 계산
      final duration1 = unitTime < 60 ? 60 : unitTime; // 최소 1시간
      final duration2 = duration1 * 2;
      final duration3 = duration1 * 3;

      fee1 = parkingLot.calculateFee(duration1);
      fee2 = parkingLot.calculateFee(duration2);
      fee3 = parkingLot.calculateFee(duration3);

      label1 = _formatDuration(duration1);
      label2 = _formatDuration(duration2);
      label3 = _formatDuration(duration3);
    }

    return VStack([
      HStack([
        const Icon(Icons.payments, size: 20, color: Colors.grey),
        8.widthBox,
        '주차 요금'.text.size(14).bold.make(),
      ]),
      8.heightBox,
      VStack([
        HStack([
          (isValet ? '발렛 요금' : '기본 요금').text.size(13).gray600.make(),
          Spacer(),
          '${basePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원${isValet ? '' : ' (최초 ${_formatDuration(unitTime)})'}'
              .text
              .size(13)
              .semiBold
              .make(),
        ]),
        4.heightBox,
        HStack([
          (isValet ? '주차 요금' : '추가 요금').text.size(13).gray600.make(),
          Spacer(),
          '${unitPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 / ${_formatDuration(unitTime)}'
              .text
              .size(13)
              .semiBold
              .make(),
        ]),
        8.heightBox,
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: VStack([
            '예상 요금'.text.size(12).bold.color(Colors.blue.shade700).make(),
            4.heightBox,
            HStack([
              label1.text.size(12).gray600.make(),
              Spacer(),
              '${fee1.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                  .text
                  .size(12)
                  .semiBold
                  .make(),
            ]),
            HStack([
              label2.text.size(12).gray600.make(),
              Spacer(),
              '${fee2.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                  .text
                  .size(12)
                  .semiBold
                  .make(),
            ]),
            HStack([
              label3.text.size(12).gray600.make(),
              Spacer(),
              '${fee3.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                  .text
                  .size(12)
                  .semiBold
                  .make(),
            ]),
          ]),
        ),
      ]).pOnly(left: 28),
    ]);
  }

  /// 길찾기 열기 (지도 선택 바텀시트)
  void _openNavigation(BuildContext context) async {
    await NavigationSelectionSheet.show(context, parkingLot);
  }
}
