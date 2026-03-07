import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/utils/phone_number_utils.dart';
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
        actions: [
          'LIVE'.text
              .color(Colors.green)
              .size(10)
              .bold
              .make()
              .pSymmetric(v: 4, h: 10)
              .box
              .roundedLg
              .color(Vx.green50)
              .make(),
          8.widthBox,
        ],
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
            .color(currentIndex == index ? Colors.black : Colors.grey.shade800)
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
            driverName: reservation.handledByStaffName,
            driverPhone: reservation.handledByStaffPhone,
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
    String? driverName,
    String? driverPhone,
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
                  .centered(),
              16.heightBox,

              // 차량 정보
              _buildCarInfo(reservation),

              // 입차 정보
              _buildEntryInfo(reservation),

              // 출차 정보
              _buildExitInfo(reservation),

              // 예약 시간
              _buildReservationTimeInfo(reservation),

              // 메모 - 완료/취소 제외
              if (status != 'completed' && status != 'cancelled')
                _buildMemoSection(reservation),

              // 기사 정보 - 승인됨 상태만
              if ((status == 'approved' || status == 'confirmed') &&
                  driverName != null)
                _buildDriverInfo(driverName, driverPhone, reservation.profileImageUrl),

              // 출차 요청 버튼 - confirmed 상태이고 출차 예정 시간이 없을 때만 표시
              if (status == 'confirmed' &&
                  (reservation.expectedExit == null || reservation.expectedExit!.trim().isEmpty))
                _buildExitRequestButton(reservation)
              // 취소 버튼 - pending 상태일 때만 표시
              else if (status == 'pending')
                _buildCancelButton(reservation)
              else
                // 버튼이 없을 때도 동일한 하단 여백 유지
                VxBox().height(24).make(),
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
      // 주차장 이름
      (reservation.parkingLotName ?? '주차장').text.size(18).bold.make(),
      Spacer(),

      // 상태 표시
      HStack([
            Icon(
              statusInfo['icon'] as IconData,
              color: statusInfo['textColor'] as Color,
              size: 14,
            ),
            4.widthBox,
            statusInfo['label']
                .toString()
                .text
                .size(12)
                .color(statusInfo['textColor'] as Color)
                .semiBold
                .make(),
          ])
          .pSymmetric(v: 4, h: 10)
          .box
          .roundedLg
          .color(statusInfo['bgColor'] as Color)
          .make(),
    ]).p16();
  }

  /// 상태 정보 가져오기
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': '대기중',
          'bgColor': Vx.orange200,
          'textColor': Vx.orange800,
          'icon': Icons.access_time_outlined,
        };
      case 'approved':
        return {
          'label': '승인됨',
          'bgColor': Vx.green200,
          'textColor': Vx.green800,
          'icon': Icons.check_circle_outline,
        };
      case 'confirmed':
        return {
          'label': '입차됨',
          'bgColor': Vx.green200,
          'textColor': Vx.green800,
          'icon': Icons.check_circle,
        };
      case 'exitRequested':
        return {
          'label': '출차 요청',
          'bgColor': Vx.blue200,
          'textColor': Vx.blue800,
          'icon': Icons.directions_car_outlined,
        };
      case 'completed':
        return {
          'label': '완료',
          'bgColor': Vx.blue200,
          'textColor': Vx.blue800,
          'icon': Icons.done_all,
        };
      case 'cancelled':
        return {
          'label': '취소됨',
          'bgColor': Vx.red200,
          'textColor': Vx.red800,
          'icon': Icons.cancel_outlined,
        };
      default:
        return {
          'label': '알 수 없음',
          'bgColor': Colors.grey.shade200,
          'textColor': Colors.grey.shade800,
          'icon': Icons.help_outline,
        };
    }
  }

  /// 차량 정보
  Widget _buildCarInfo(Reservation reservation) {
    return HStack([
      Icon(Icons.directions_car_filled, color: Colors.grey.shade500, size: 18),
      4.widthBox,
      (reservation.visitorVehiclePlate ?? '차량번호 없음').text
          .size(14)
          .color(Vx.black)
          .semiBold
          .make(),
    ]).pSymmetric(v: 4, h: 12);
  }

  /// 입차 정보
  Widget _buildEntryInfo(Reservation reservation) {
    final entryTime = reservation.actualArrival ?? reservation.expectedArrival;
    final isActual = reservation.actualArrival != null;

    return HStack([
      Icon(
        isActual ? Icons.login : Icons.login_outlined,
        color: isActual ? Colors.blue : Colors.grey.shade500,
        size: 18,
      ),
      8.widthBox,
      '입차${isActual ? " 완료" : " 예정"}'.text.size(14).color(Colors.grey.shade500).make(),
      12.widthBox,
      _formatDateTime(
        entryTime,
      ).text.size(14).color(Colors.black).fontWeight(FontWeight.w400).make(),
    ]).pSymmetric(v: 4, h: 12);
  }

  /// 출차 정보
  Widget _buildExitInfo(Reservation reservation) {
    // actualExit이 있으면 우선 사용, 없으면 expectedExit 사용
    final exitTime = reservation.actualExit ?? reservation.expectedExit;
    final isActual = reservation.actualExit != null;
    final hasExit = exitTime != null && exitTime.isNotEmpty;
    final isExitRequested = reservation.status == ReservationStatus.exitRequested;

    return HStack([
      Icon(
        isActual ? Icons.logout : Icons.logout_outlined,
        color: isActual ? Colors.blue : Colors.grey.shade500,
        size: 18,
      ),
      8.widthBox,
      '출차${isActual ? " 완료" : hasExit ? " 예정" : ""}'.text.size(14).color(Colors.grey.shade500).make(),
      12.widthBox,
      (isExitRequested
              ? '출차 요청 승인 대기중'
              : hasExit
                  ? _formatDateTime(exitTime)
                  : '미정')
          .text
          .size(14)
          .color(isExitRequested ? Colors.orange : Colors.black)
          .fontWeight(FontWeight.w400)
          .make(),
    ]).pSymmetric(v: 4, h: 12);
  }

  /// 예약 시간 정보
  Widget _buildReservationTimeInfo(Reservation reservation) {
    return HStack([
      Icon(Icons.access_time_rounded, color: Colors.grey.shade500, size: 18),
      8.widthBox,
      '예약'.text.size(14).color(Colors.grey.shade500).make(),
      12.widthBox,
      _formatDateTime(
        reservation.createdAt,
      ).text.size(12).color(Colors.black).fontWeight(FontWeight.w300).make(),
    ], crossAlignment: CrossAxisAlignment.start).pSymmetric(v: 4, h: 12);
  }

  /// 날짜/시간 포맷팅
  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final weekday = ['월', '화', '수', '목', '금', '토', '일'][dateTime.weekday - 1];
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  /// 기사 정보 (승인됨 상태만)
  Widget _buildDriverInfo(String name, String? phone, String? profileImageUrl) {
    return VStack([
          HStack([
            Icon(Icons.check_circle_outline, color: Vx.green700, size: 14),
            8.widthBox,
            '배정된 기사님'.text.size(12).color(Vx.green700).semiBold.make(),
            12.widthBox,
          ]),
          8.heightBox,

          HStack([
            // 프로필 이미지 (있으면 네트워크 이미지, 없으면 아이콘)
            profileImageUrl != null && profileImageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profileImageUrl,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                          size: 20,
                        ).p4().box.roundedFull.color(Colors.grey.shade50).make();
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey.shade500,
                    size: 20,
                  ).p4().box.roundedFull.color(Colors.grey.shade50).make(),
            12.widthBox,
            VStack([
              '$name 기사님'.text.size(14).color(Colors.black).bold.make(),
              PhoneNumberUtils.globalToKorea(phone!).text
                  .size(12)
                  .color(Colors.grey.shade600)
                  .fontWeight(FontWeight.w400)
                  .make(),
            ]),
            Spacer(),
          ]),
        ])
        .pSymmetric(v: 12, h: 12)
        .box
        .rounded
        .green50
        .border(color: Vx.green100)
        .make()
        .px12();
  }

  /// 메모 섹션
  Widget _buildMemoSection(Reservation reservation) {
    if (reservation.notes == null || reservation.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return VStack([
          HStack([
            Icon(
              Icons.description_outlined,
              color: Colors.grey.shade700,
              size: 16,
            ),
            8.widthBox,
            Expanded(
              child: '메모'.text
                  .size(12)
                  .color(Colors.grey.shade700)
                  .semiBold
                  .make(),
            ),
          ]),
          8.heightBox,

          reservation.notes!.text
              .size(12)
              .color(Colors.black)
              .fontWeight(FontWeight.w200)
              .make(),
        ])
        .pSymmetric(v: 12, h: 16)
        .box
        .rounded
        .color(Colors.grey.shade50)
        .border(color: Colors.grey.shade200)
        .make()
        .pSymmetric(v: 8, h: 12);
  }

  /// 취소 버튼
  Widget _buildCancelButton(Reservation reservation) {
    return GestureDetector(
      onTap: () async {
        // 취소 확인 다이얼로그
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('예약 취소'),
            content: const Text('예약을 취소하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('예', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          try {
            final controller = ref.read(userReservationControllerProvider);
            final currentUser = ref.read(currentAuthUserProvider);
            if (currentUser != null) {
              await controller.cancelReservation(
                reservation.id,
                currentUser.uid,
              );
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('예약이 취소되었습니다')));
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('취소 실패: $e')));
            }
          }
        }
      },
      child: '예약 취소'.text
          .color(Vx.red600)
          .fontWeight(FontWeight.w500)
          .size(16)
          .makeCentered()
          .py8()
          .box
          .rounded
          .color(Vx.white)
          .border(color: Vx.red100)
          .make()
          .pOnly(top: 8, left: 12, right: 12, bottom: 16),
    );
  }

  /// 출차 요청 버튼
  Widget _buildExitRequestButton(Reservation reservation) {
    return GestureDetector(
      onTap: () async {
        // 출차 예정 시간 선택
        final selectedDateTime = await _showExitTimePickerDialog(reservation);

        if (selectedDateTime == null) {
          return; // 사용자가 취소한 경우
        }

        // 출차 요청 확인 다이얼로그
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('출차 요청', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: VStack([
                '출차를 요청하시겠습니까?'.text.size(15).make(),
                16.heightBox,
                VStack([
                  '출차 예정 시간'.text.size(13).color(Colors.grey.shade600).make(),
                  4.heightBox,
                  _formatDateTime(selectedDateTime.toIso8601String())
                      .text
                      .size(16)
                      .bold
                      .color(Vx.purple700)
                      .make(),
                ])
                    .p12()
                    .box
                    .roundedSM
                    .color(Vx.purple50)
                    .make(),
                16.heightBox,
                '기사님께서 승인 후 출차 시간이 확정됩니다.'
                    .text
                    .size(13)
                    .color(Colors.grey.shade600)
                    .center
                    .make(),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('취소', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('출차 요청', style: TextStyle(fontSize: 15, color: Colors.purple, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          try {
            final controller = ref.read(userReservationControllerProvider);
            final currentUser = ref.read(currentAuthUserProvider);
            if (currentUser != null) {
              await controller.requestExit(
                reservation.id,
                currentUser.uid,
                selectedDateTime,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('출차 요청이 접수되었습니다')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('출차 요청 실패: $e')),
              );
            }
          }
        }
      },
      child: '출차 요청'.text
          .color(Vx.blue600)
          .fontWeight(FontWeight.w500)
          .size(16)
          .makeCentered()
          .py8()
          .box
          .rounded
          .color(Vx.blue50)
          .border(color: Vx.blue600)
          .make()
          .pOnly(top: 8, left: 12, right: 12, bottom: 16),
    );
  }

  /// 출차 시간 선택 다이얼로그
  Future<DateTime?> _showExitTimePickerDialog(Reservation reservation) async {
    final now = DateTime.now();
    final minDateTime = now.add(const Duration(hours: 2));

    // 날짜 선택
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: minDateTime,
      firstDate: minDateTime,
      lastDate: now.add(const Duration(days: 30)),
      helpText: '출차 예정 날짜 선택',
      confirmText: '다음',
      cancelText: '취소',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Vx.blue600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) {
      return null;
    }

    // 시간 선택
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: minDateTime.hour,
        minute: minDateTime.minute,
      ),
      helpText: '출차 예정 시간 선택',
      confirmText: '확인',
      cancelText: '취소',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Vx.blue600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) {
      return null;
    }

    // 날짜와 시간 결합
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // 현재 시간 + 2시간 이후인지 검증
    if (selectedDateTime.isBefore(minDateTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('출차 예정 시간은 현재 시간으로부터 2시간 이후여야 합니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    return selectedDateTime;
  }
}
