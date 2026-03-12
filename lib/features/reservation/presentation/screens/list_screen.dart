import 'package:daeja/core/constants/colors.dart';
import 'package:daeja/core/services/price_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../providers/user_reservation_provider.dart';
import '../../domain/models/reservation.dart';
import 'reservation_detail_screen.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 확인
    final currentUser = ref.watch(currentAuthUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: '내 예약 목록'.text.size(18).bold.make(),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      backgroundColor: Colors.grey.shade100,
      body: currentUser == null
          ? _buildLoginRequired()
          : _buildReservationList(currentUser.uid),
    );
  }

  /// 로그인 필요 UI
  Widget _buildLoginRequired() {
    return Center(
      child: VStack([
        Icon(Icons.login_rounded, size: 80, color: Colors.grey.shade400),
        24.heightBox,
        '로그인이 필요합니다'.text.size(20).bold.color(Colors.grey.shade700).make(),
        12.heightBox,
        '예약 내역을 확인하려면\n로그인해주세요'.text
            .size(14)
            .color(Colors.grey.shade500)
            .center
            .make(),
        32.heightBox,
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignInScreen()),
            );
          },
          child: '로그인하기'.text
              .size(16)
              .white
              .bold
              .make()
              .centered()
              .p16()
              .box
              .rounded
              .blue500
              .make()
              .w(200),
        ),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }

  /// 예약 목록 UI
  Widget _buildReservationList(String userId) {
    final reservationsAsync = ref.watch(myReservationsProvider(userId));

    return reservationsAsync.when(
      data: (reservations) {
        // 예약이 없는 경우
        if (reservations.isEmpty) {
          return _buildEmptyReservations();
        }

        // 상태별로 분류
        final pendingList = reservations
            .where((r) => r.status == ReservationStatus.pending)
            .toList();
        final approvedList = reservations
            .where(
              (r) =>
                  r.status == ReservationStatus.approved ||
                  r.status == ReservationStatus.confirmed ||
                  r.status == ReservationStatus.exitRequested,
            )
            .toList();
        final completedList = reservations
            .where((r) => r.status == ReservationStatus.completed)
            .toList();
        final cancelledList = reservations
            .where((r) => r.status == ReservationStatus.cancelled)
            .toList();

        final activeList = [...pendingList, ...approvedList];

        return SingleChildScrollView(
          child: SafeArea(
            child: VStack([
              // Tab Bar
              _buildMyTabBar(currentTabIndex),

              // 전체 (0) - 모든 예약 표시
              if (currentTabIndex == 0) ...[
                if (activeList.isNotEmpty) _buildActiveReservations(activeList),
                if (completedList.isNotEmpty)
                  _buildCompletedReservations(completedList),
                if (cancelledList.isNotEmpty)
                  _buildCancelledReservations(cancelledList),
              ],

              // 활성 (1) - 활성 예약만
              if (currentTabIndex == 1)
                activeList.isNotEmpty
                    ? _buildActiveReservations(activeList)
                    : _buildEmptySection('활성 예약이 없습니다'),

              // 완료 (2) - 완료된 예약만
              if (currentTabIndex == 2)
                completedList.isNotEmpty
                    ? _buildCompletedReservations(completedList)
                    : _buildEmptySection('완료된 예약이 없습니다'),

              // 취소 (3) - 취소된 예약만
              if (currentTabIndex == 3)
                cancelledList.isNotEmpty
                    ? _buildCancelledReservations(cancelledList)
                    : _buildEmptySection('취소된 예약이 없습니다'),
            ]).pOnly(top: 4, bottom: 8),
          ),
        );
      },
      loading: () => Center(
        child: VStack([
          const CircularProgressIndicator(),
          16.heightBox,
          '예약 정보 불러오는 중...'.text.color(Colors.grey.shade600).make(),
        ]),
      ),
      error: (error, stack) => Center(
        child: VStack([
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          16.heightBox,
          '예약 정보를 불러올 수 없습니다'.text.size(16).color(Colors.grey.shade700).make(),
          8.heightBox,
          error
              .toString()
              .text
              .size(12)
              .color(Colors.grey.shade500)
              .center
              .make(),
        ]),
      ),
    );
  }

  /// 예약 없음 UI
  Widget _buildEmptyReservations() {
    return Center(
      child: VStack([
        Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
        24.heightBox,
        '예약 내역이 없습니다'.text.size(18).color(Colors.grey.shade600).make(),
        12.heightBox,
        '새로운 예약을 만들어보세요'.text.size(14).color(Colors.grey.shade400).make(),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }

  /// 빈 섹션 UI
  Widget _buildEmptySection(String message) {
    return Center(
      child: VStack([
        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
        16.heightBox,
        message.text.size(16).color(Colors.grey.shade500).make(),
      ], crossAlignment: CrossAxisAlignment.center).p32(),
    );
  }

  Widget _buildMyTabBar(int currentIndex) {
    return HStack([
          _buildTab('전체', 0, currentIndex),
          _buildTab('활성', 1, currentIndex),
          _buildTab('완료', 2, currentIndex),
          _buildTab('취소', 3, currentIndex),
        ])
        .p(4)
        .box
        .roundedSM
        .color(Colors.grey.shade200)
        .make()
        .pSymmetric(v: 12, h: 16)
        .box
        .color(Colors.white)
        .make()
        .wFull(context);
  }

  Widget _buildTab(String label, int index, int currentIndex) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            currentTabIndex = index;
          });
        },
        child: label.text
            .size(14)
            .fontWeight(
              currentIndex == index ? FontWeight.w600 : FontWeight.w500,
            )
            .color(currentIndex == index ? mainColor : Colors.grey.shade800)
            .makeCentered()
            .pSymmetric(v: 6)
            .box
            .roundedSM
            .color(currentIndex == index ? Colors.white : Colors.transparent)
            .make(),
      ),
    );
  }

  Widget _buildActiveReservations(List<Reservation> reservations) {
    return VStack([
      // title
      _buildTitle(Vx.green700, '활성 예약', reservations.length),

      // 예약 리스트
      ...reservations.map((reservation) {
        return VStack([
          _buildReservationContainer(
            reservation.status.name,
            reservation: reservation,
          ),
          8.heightBox,
        ]);
      }),
    ]).pSymmetric(h: 16);
  }

  Widget _buildCompletedReservations(List<Reservation> reservations) {
    return VStack([
      // title
      _buildTitle(Vx.blue700, '완료된 예약', reservations.length),

      // 예약 리스트
      ...reservations.map((reservation) {
        return VStack([
          _buildReservationContainer('completed', reservation: reservation),
          8.heightBox,
        ]);
      }),
    ]).pSymmetric(h: 16);
  }

  Widget _buildCancelledReservations(List<Reservation> reservations) {
    return VStack([
      // title
      _buildTitle(Vx.red700, '취소된 예약', reservations.length),

      // 예약 리스트
      ...reservations.map((reservation) {
        return VStack([
          _buildReservationContainer('cancelled', reservation: reservation),
          8.heightBox,
        ]);
      }),
    ]).pSymmetric(h: 16);
  }

  Widget _buildTitle(Color color, String title, int count) {
    return HStack([
      // Bar
      VxBox()
          .width(4)
          .height(24)
          .color(color)
          .make()
          .centered()
          .pSymmetric(v: 12),
      8.widthBox,

      // Title
      title.text.size(16).bold.make(),
      8.widthBox,

      // Count
      count.text
          .color(color)
          .size(12)
          .bold
          .make()
          .p8()
          .box
          .roundedFull
          .color(color.withAlpha(30))
          .make(),
    ]);
  }

  Widget _buildReservationContainer(
    String status, {
    required Reservation reservation,
  }) {
    final container =
        VStack([
              // 헤더 (주차장 이름 + 상태 배지)
              _buildReservationHeader(status, reservation),

              // Divider
              VxBox()
                  .width(double.infinity)
                  .height(1)
                  .color(Colors.grey.shade300)
                  .make()
                  .px16()
                  .centered(),

              // 상태별 시간 정보
              HStack([
                _buildStatusTimeInfo(reservation).expand(),
                _buildPrice(reservation),
              ]).py4(),
            ]).box.rounded
            .border(color: Colors.grey.shade300)
            .color(
              status == 'completed' || status == 'cancelled'
                  ? Colors.grey.shade50
                  : Colors.white,
            )
            .make();

    // 완료/취소된 예약은 전체적으로 회색톤으로 표시
    final Widget finalContainer =
        (status == 'completed' || status == 'cancelled')
        ? Opacity(opacity: 0.6, child: container)
        : container;

    // 클릭 시 상세 페이지로 이동
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReservationDetailScreen(reservation: reservation),
          ),
        );
      },
      child: finalContainer,
    );
  }

  /// 예약 헤더 (주차장 이름 + 상태 배지)
  Widget _buildReservationHeader(String status, Reservation reservation) {
    final statusInfo = _getStatusInfo(status);
    return HStack([
      // 정보
      VStack([
        // 상태 표시
        statusInfo['label']
            .toString()
            .text
            .size(13)
            .color(statusInfo['textColor'] as Color)
            .extraBold
            .make()
            .pSymmetric(v: 2, h: 10)
            .box
            .roundedLg
            .color(statusInfo['bgColor'] as Color)
            .make(),
        16.heightBox,

        // 주차장 이름
        (reservation.parkingLotName ?? '주차장').text.size(18).bold.make(),

        _buildCarInfo(reservation),
      ], axisSize: MainAxisSize.min),

      Spacer(),
      // 아이콘
      Icon(Icons.arrow_forward_ios, size: 14).px2().py8(),
    ], crossAlignment: CrossAxisAlignment.start).p16();
  }

  /// 상태 정보 가져오기
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': '대기중',
          'bgColor': Vx.orange200,
          'textColor': Vx.orange800,
        };
      case 'approved':
        return {
          'label': '승인됨',
          'bgColor': Vx.green200,
          'textColor': Vx.green800,
        };
      case 'confirmed':
        return {
          'label': '입차됨',
          'bgColor': Vx.green200,
          'textColor': Vx.green800,
        };
      case 'exitRequested':
        return {
          'label': '출차 요청',
          'bgColor': Vx.blue200,
          'textColor': Vx.blue800,
        };
      case 'completed':
        return {'label': '완료', 'bgColor': Vx.blue200, 'textColor': Vx.blue800};
      case 'cancelled':
        return {'label': '취소됨', 'bgColor': Vx.red200, 'textColor': Vx.red800};
      default:
        return {
          'label': '알 수 없음',
          'bgColor': Colors.grey.shade200,
          'textColor': Colors.grey.shade800,
        };
    }
  }

  /// 차량 정보
  Widget _buildCarInfo(Reservation reservation) {
    return HStack([
      Icon(Icons.directions_car_outlined, color: Vx.black, size: 15),
      4.widthBox,

      (reservation.visitorVehicleManufacturer ?? '').text
          .size(14)
          .color(Vx.black)
          .make(),
      2.widthBox,
      (reservation.visitorVehicleModel ?? '').text
          .size(14)
          .color(Vx.black)
          .make(),

      VxBox().roundedFull.size(5, 5).color(Vx.black).make().px4(),

      (reservation.visitorVehiclePlate ?? '차량번호 없음').text
          .size(14)
          .color(Vx.black)
          .make(),
    ]).py4();
  }

  /// 상태별 시간 정보
  Widget _buildStatusTimeInfo(Reservation reservation) {
    String title;
    String data;

    switch (reservation.status) {
      case ReservationStatus.pending:
        title = '예약 생성';
        data = _formatDateTime(reservation.createdAt);
      case ReservationStatus.approved:
        title = '입차 시간';
        data = _formatDateTime(reservation.expectedArrival);
      case ReservationStatus.confirmed:
        title = '출차 시간';
        data =
            (reservation.expectedExit != null &&
                reservation.expectedExit!.trim().isNotEmpty)
            ? _formatDateTime(reservation.expectedExit!)
            : '출차 요청 해주세요.';
      case ReservationStatus.exitRequested:
        title = '출차 요청';
        data = reservation.expectedExit != null
            ? _formatDateTime(reservation.expectedExit!)
            : '미정';
      case ReservationStatus.completed:
        title = '출차 완료';
        data = reservation.actualExit != null
            ? _formatDateTime(reservation.actualExit!)
            : '미정';
      case ReservationStatus.cancelled:
        title = '예약 생성';
        data = _formatDateTime(reservation.createdAt);
    }

    return '$title: $data'.text
        .size(12)
        .color(Colors.black)
        .make()
        .pSymmetric(v: 4, h: 12);
  }

  /// 날짜/시간 포맷팅
  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildPrice(Reservation reservation) {
    if (reservation.valetFee == null || reservation.dailyParkingFee == null) {
      return const SizedBox.shrink();
    }

    final exitTimeStr = reservation.actualExit ?? reservation.expectedExit;
    if (exitTimeStr == null || exitTimeStr.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final arrivalTime = DateTime.parse(reservation.expectedArrival);
      final exitTime = DateTime.parse(exitTimeStr);
      final totalFee = PriceService.calculateTotalFee(
        arrivalTime,
        exitTime,
        reservation.valetFee!,
        reservation.dailyParkingFee!,
      );

      return PriceService.formatCurrency(
        totalFee,
      ).text.color(Vx.black).size(18).bold.make().pSymmetric(v: 4, h: 12);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
