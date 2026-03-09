import 'package:daeja/core/widgets/button/big_button.dart';
import 'package:daeja/features/parking/domain/models/parking_lot.dart';
import 'package:daeja/features/parking/presentation/providers/parking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class ReservationCompleteView extends StatelessWidget {
  final ParkingLot parkingLot;
  final String? vehiclePlate;
  final DateTime expectedArrival;
  final DateTime? expectedExit;
  final int? fee;

  const ReservationCompleteView({
    super.key,
    required this.parkingLot,
    this.vehiclePlate,
    required this.expectedArrival,
    this.expectedExit,
    this.fee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: '예약 확인'.text.size(18).bold.make(),
        centerTitle: true,
      ),
      body: VStack([
        _buildCheckIcon(),
        12.heightBox,

        '예약요청 전송완료'.text.size(20).bold.makeCentered(),
        4.heightBox,
        VStack([
          '예약 요청이 전송되었습니다.'.text
              .size(14)
              .color(Colors.grey.shade600)
              .makeCentered(),
          '예약이 승인되면 알림으로 알려드립니다.'.text
              .size(14)
              .color(Colors.grey.shade600)
              .makeCentered(),
        ]),
        24.heightBox,

        // 예약 상세
        '예약 상세'.text.size(14).color(Colors.grey.shade600).semiBold.make(),
        4.heightBox,
        VStack([
              // 예약 주차장
              '예약된 주차장'.text.size(12).color(Colors.grey.shade600).make(),
              2.heightBox,
              parkingLot.name.text.size(14).bold.make(),

              Divider(),
              // 전화번호
              VStack([
                HStack([
                  '전화번호'.text.size(12).color(Colors.grey.shade600).make(),
                  Spacer(),
                  (parkingLot.tel ?? '').text.size(14).bold.make(),
                ]),
                '도착 10분 전 전화요청 부탁드립니다!'.text
                    .size(12)
                    .color(Colors.redAccent)
                    .bold
                    .make(),
              ], crossAlignment: CrossAxisAlignment.end),

              Divider(),
              // 발렛 예약 시간
              HStack([
                '발렛 예약 시간'.text.size(12).color(Colors.grey.shade600).make(),
                Spacer(),
                _formatDateTime(
                  expectedArrival,
                ).toString().text.size(14).bold.make(),
              ]),

              Divider(),
              // 출차 사간
              HStack([
                '출차 시간'.text.size(12).color(Colors.grey.shade600).make(),
                Spacer(),
                expectedExit != null
                    ? _formatDateTime(
                        expectedExit!,
                      ).toString().text.size(14).bold.make()
                    : '미정'.text.size(14).bold.make(),
              ]),

              Divider(),
              // 차량정보
              HStack([
                '차량 번호'.text.size(12).color(Colors.grey.shade600).make(),
                Spacer(),
                vehiclePlate.toString().text.size(14).bold.make(),
              ]),
            ])
            .p16()
            .box
            .rounded
            .color(Color(0xFFF0F1FF))
            .border(color: Color(0xFF7779EC).withOpacity(0.2))
            .make()
            .wFull(context),
        16.heightBox,

        // 결제 정보
        '결제 정보'.text.size(14).color(Colors.grey.shade600).semiBold.make(),
        4.heightBox,
        VStack([
              // 결제 계좌
              HStack([
                VStack([
                  '입금 계좌'.text.size(12).color(Colors.grey.shade600).make(),
                  2.heightBox,
                  parkingLot.accountNumber!.text.size(14).bold.make(),
                ]),
                Spacer(),
                Icon(Icons.copy, size: 18, color: Color(0xFF7779EC))
                    .p12()
                    .box
                    .rounded
                    .color(Color(0xFF7779EC).withOpacity(0.2))
                    .make()
                    .onInkTap(() {
                      Clipboard.setData(
                        ClipboardData(text: parkingLot.accountNumber!),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('계좌번호가 클립보드에 복사되었습니다.')),
                      );
                    }),
              ]),

              Divider(),
              // 발렛 예약 시간
              HStack([
                '예상 가격'.text.size(14).semiBold.make(),
                Spacer(),
                if (fee != null)
                  '￦${fee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                      .text
                      .size(20)
                      .color(Color(0xFF7779EC))
                      .bold
                      .make()
                else
                  '미정'.text.color(Colors.grey.shade600).bold.make(),
              ]).p16().box.rounded.color(Color(0xFF7779EC).withOpacity(0.2)).make(),
            ])
            .p16()
            .box
            .rounded
            .color(Color(0xFFF0F1FF))
            .border(color: Color(0xFF7779EC).withOpacity(0.2))
            .make()
            .wFull(context),

        12.heightBox,
        HStack([
              // Icon
              Icon(Icons.info, size: 22, color: Color(0xFF7779EC)),
              4.widthBox,
              // 문구
              '원활한 출차를 위해 방문전 미리 결제를 완료해주세요.\n(추가 상품은 별도로 계산하여 입금 부탁드립니다.)'.text
                  .color(Color(0xFF7779EC))
                  .make()
                  .expand(),
            ], crossAlignment: CrossAxisAlignment.start)
            .p16()
            .box
            .rounded
            .color(Color(0xFF7779EC).withOpacity(0.2))
            .border(color: Color(0xFF7779EC))
            .make()
            .wFull(context),
      ]).py12().px16().scrollVertical(),
    );
  }

  Widget _buildCheckIcon() {
    return Icon(
      Icons.check,
      size: 40,
      color: Colors.white,
    ).p16().box.roundedFull.color(Color(0xFF7779EC)).makeCentered();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}. ${dateTime.month.toString().padLeft(2, '0')}. ${dateTime.day.toString().padLeft(2, '0')}. '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
