import 'package:daeja/features/reservation/presentation/screens/reservation_screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../domain/models/parking_lot.dart';
import '../navigation_selection_sheet.dart';

class ValetParkingSheet extends StatelessWidget {
  final ParkingLot parkingLot;

  const ValetParkingSheet({super.key, required this.parkingLot});

  static void show(BuildContext context, ParkingLot parkingLot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ValetParkingSheet(parkingLot: parkingLot),
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
            // Title
            HStack([
              // 왼쪽
              VStack([
                // 주차장 타입
                'PREMIUM VALET'.text
                    .size(10)
                    .semiBold
                    // .color(Color(0xFF6466E9)) // 블랙
                    .color(Color(0xFF6466E9)) // 화이트
                    .make()
                    .py2()
                    .px8()
                    .box
                    .roundedSM
                    // .color(Color(0xFF21264E)) // 블랙
                    .color(Color(0xFFF0F1FF)) // 화이트
                    .make(),
                4.heightBox,
                // 주차장 이름
                parkingLot.name.text.size(18).black.bold.make(),
                4.heightBox,
              ]),

              Spacer(),

              // 오른쪽
              VStack([
                parkingLot.availableSpots.text
                    .color(Color(0xFF6466E9))
                    .size(20)
                    .bold
                    .make(),
                '/${parkingLot.totalSpots}'.text.size(12).gray500.medium.make(),
              ], crossAlignment: CrossAxisAlignment.end),
            ]),

            // 주소
            HStack([
              const Icon(Icons.location_on, size: 18, color: Colors.black26),
              4.widthBox,
              parkingLot.address.text.size(14).gray500.medium.make().expand(),
            ], crossAlignment: CrossAxisAlignment.center),
            12.heightBox,

            // 요금 정보
            if (parkingLot.basePrice != null &&
                parkingLot.unitTime != null &&
                parkingLot.unitPrice != null) ...[
              _buildPricing(),
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

            HStack([
              // 예약하기 버튼 (80%)
              HStack([
                    Icon(Icons.local_parking, color: Colors.white, size: 20),
                    6.widthBox,
                    '예약하기'.text.white.bold.size(14).make(),
                  ])
                  .centered()
                  .p20()
                  .box
                  .color(const Color(0xFF7779EC))
                  .rounded
                  .make()
                  .onInkTap(() => _openReservation(context))
                  .expand(flex: 80),

              12.widthBox,

              // 길찾기 버튼 (20%)
              Icon(Icons.navigation, color: Color(0xFF7779EC), size: 20)
                  .centered()
                  .p20()
                  .box
                  .color(Color(0xFFF0F1FF))
                  .rounded
                  .border(color: const Color(0xFF7779EC).withOpacity(0.2))
                  .make()
                  .onInkTap(() => _openNavigation(context))
                  .expand(flex: 20),
            ]),

            12.heightBox,
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

  Widget _buildPricing() {
    final basePrice = parkingLot.basePrice!;
    final unitTime = parkingLot.unitTime!;
    final unitPrice = parkingLot.unitPrice!;

    return HStack([
      Container(
        padding: const EdgeInsets.all(12), // 여백을 조금 더 넓게
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1FF), // 배경: 아주 연한 보라 (프리미엄 화이트)
          borderRadius: BorderRadius.circular(12), // 조금 더 둥글게 (고급스러움)
          border: Border.all(
            color: const Color(0xFF7779EC).withOpacity(0.2),
          ), // 은은한 테두리
        ),
        child: VStack([
          HStack([
            const Icon(Icons.hail, size: 18, color: Color(0xFF7779EC)),
            4.widthBox,
            '발렛 요금'.text.size(13).bold.color(const Color(0xFF7779EC)).make(),
          ]),
          10.heightBox,
          // 실제 요금이 들어갈 자리 (예시)
          HStack([
            '₩'.text.size(12).gray600.bold.make(),
            4.widthBox,
            basePrice.text.size(20).bold.black.make(),
          ], crossAlignment: CrossAxisAlignment.center),
        ], crossAlignment: CrossAxisAlignment.center),
      ).expand(),

      16.widthBox,

      Container(
        padding: const EdgeInsets.all(12), // 여백을 조금 더 넓게
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1FF), // 배경: 아주 연한 보라 (프리미엄 화이트)
          borderRadius: BorderRadius.circular(12), // 조금 더 둥글게 (고급스러움)
          border: Border.all(
            color: const Color(0xFF7779EC).withOpacity(0.2),
          ), // 은은한 테두리
        ),
        child: VStack([
          HStack([
            const Icon(Icons.local_parking, size: 18, color: Color(0xFF7779EC)),
            4.widthBox,
            '주차 요금(일)'.text.size(13).bold.color(const Color(0xFF7779EC)).make(),
          ]),
          10.heightBox,
          // 실제 요금이 들어갈 자리
          HStack([
            '₩'.text.size(12).gray600.bold.make(),
            4.widthBox,
            unitPrice.text.size(20).bold.black.make(),
          ], crossAlignment: CrossAxisAlignment.center),
        ], crossAlignment: CrossAxisAlignment.center),
      ).expand(),
    ], alignment: MainAxisAlignment.spaceAround).pOnly(top: 8);
  }

  // 길찾기 열기 (지도 선택 바텀시트)
  void _openNavigation(BuildContext context) async {
    await NavigationSelectionSheet.show(context, parkingLot);
  }

  // 예약 화면 열기
  void _openReservation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(parkingLot: parkingLot),
      ),
    );
  }
}
