import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/utils/phone_number_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../parking/presentation/providers/parking_providers.dart';
import '../../../parking/presentation/widgets/navigation_selection_sheet.dart';
import '../../domain/models/reservation.dart';
import '../providers/user_reservation_provider.dart';

/// Ripple 애니메이션 위젯 (현재 상태 표시용)
class RippleCircle extends StatefulWidget {
  final double size;
  final Color color;

  const RippleCircle({super.key, required this.size, required this.color});

  @override
  State<RippleCircle> createState() => _RippleCircleState();
}

class _RippleCircleState extends State<RippleCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(); // 무한 반복

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3.0, // 고정 크기 (ripple이 최대로 커져도 안 밀림)
      height: widget.size * 3.0,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 하나만
              _buildRipple(_animation.value),
              // 중심 원 (고정)
              child!,
            ],
          );
        },
        child: VxBox().roundedFull
            .size(widget.size, widget.size)
            .color(widget.color)
            .make(),
      ),
    );
  }

  Widget _buildRipple(double animValue) {
    return Container(
      width: widget.size * (1 + animValue * 2.0),
      height: widget.size * (1 + animValue * 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // 연한 연두색으로 채우고 점점 투명해짐
        color: Vx.green200.withValues(alpha: (1.0 - animValue) * 0.6),
      ),
    );
  }
}

class ReservationDetailScreen extends ConsumerStatefulWidget {
  final Reservation? reservation;
  final String? reservationId;

  const ReservationDetailScreen({
    super.key,
    this.reservation,
    this.reservationId,
  }) : assert(
            reservation != null || reservationId != null,
            'Either reservation or reservationId must be provided',
          );

  @override
  ConsumerState<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState
    extends ConsumerState<ReservationDetailScreen> {

  /// 예약 상태별 UI 정보 반환
  Map<String, dynamic> _getStatusInfo(Reservation reservation) {
    final status = reservation.status;

    switch (status) {
      case ReservationStatus.pending:
        return {
          'title': '예약 대기 중입니다',
          'subtitle': '곧 승인 처리됩니다',
          'icon': Icons.access_time_outlined,
          'colorFrom': Vx.orange400,
          'colorTo': Vx.orange600,
        };
      case ReservationStatus.approved:
        return {
          'title': '예약이 승인되었습니다',
          'subtitle': '기사님이 배정되었습니다',
          'icon': Icons.check_circle_outline,
          'colorFrom': Vx.green500,
          'colorTo': Vx.green700,
        };
      case ReservationStatus.confirmed:
        return {
          'title': '입차가 완료되었습니다',
          'subtitle': '차량이 주차되었습니다',
          'icon': Icons.local_parking_outlined,
          'colorFrom': Vx.green500,
          'colorTo': Vx.green700,
        };
      case ReservationStatus.exitRequested:
        return {
          'title': '입차가 완료되었습니다',
          'subtitle': '사장님께서 확인 후 출차 시간이 확정됩니다.',
          'icon': Icons.local_parking_outlined,
          'colorFrom': Vx.green500,
          'colorTo': Vx.green700,
        };
      case ReservationStatus.completed:
        return {
          'title': '서비스가 완료되었습니다',
          'subtitle': '이용해 주셔서 감사합니다',
          'icon': Icons.done_all,
          'colorFrom': Vx.blue500,
          'colorTo': Vx.blue700,
        };
      case ReservationStatus.cancelled:
        return {
          'title': '예약이 취소되었습니다',
          'subtitle': '',
          'icon': Icons.cancel_outlined,
          'colorFrom': Vx.red400,
          'colorTo': Vx.red600,
        };
    }
  }

  /// 현재 진행 단계 계산 (0: 예약완료, 1: 승인, 2: 입차, 3: 출차)
  int _getCurrentStep(Reservation reservation) {

    // 취소됨
    if (reservation.status == ReservationStatus.cancelled) {
      return -1;
    }

    // 출차 완료
    if (reservation.status == ReservationStatus.completed || reservation.actualExit != null) {
      return 3;
    }

    // 출차 요청됨 - 입차 단계로 표시 (출차 시간 확정 대기 중)
    if (reservation.status == ReservationStatus.exitRequested) {
      return 2;
    }

    // 입차 완료 - actualArrival이 있거나 confirmed 상태면 입차 완료
    if (reservation.actualArrival != null || reservation.status == ReservationStatus.confirmed) {
      return 2;
    }

    // 승인됨
    if (reservation.status == ReservationStatus.approved) {
      return 1;
    }

    // 대기중
    if (reservation.status == ReservationStatus.pending) {
      return 0;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    double height = mq.size.height;

    // reservationId가 제공된 경우 실시간으로 데이터 로드
    if (widget.reservationId != null) {
      final reservationAsync = ref.watch(
        reservationStreamProvider(widget.reservationId!),
      );

      return reservationAsync.when(
        data: (reservation) {
          if (reservation == null) {
            return Scaffold(
              appBar: AppBar(title: '예약 상세'.text.make()),
              body: Center(
                child: '예약을 찾을 수 없습니다.'.text.size(16).make(),
              ),
            );
          }
          // 데이터가 있으면 아래 일반 build 로직 실행
          return _buildNormalContent(context, height, reservation);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: '예약 상세'.text.make()),
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: '예약 상세'.text.make()),
          body: Center(
            child: '예약 정보를 불러올 수 없습니다.'.text.size(16).make(),
          ),
        ),
      );
    }

    // reservation 객체가 직접 제공된 경우
    return _buildNormalContent(context, height, widget.reservation!);
  }

  Widget _buildNormalContent(BuildContext context, double height, Reservation reservation) {
    final statusInfo = _getStatusInfo(reservation);
    final currentStep = _getCurrentStep(reservation);

    // 디버깅: 출차 관련 데이터 확인
    print('🔍 [예약 상세] status: ${reservation.status}');
    print('🔍 [예약 상세] expectedExit: ${reservation.expectedExit}');
    print('🔍 [예약 상세] actualExit: ${reservation.actualExit}');
    print('🔍 [예약 상세] expectedExit == null: ${reservation.expectedExit == null}');
    print('🔍 [예약 상세] expectedExit.isEmpty: ${reservation.expectedExit?.isEmpty}');

    // 출차 요청 버튼 표시 여부 (입차 완료이고 아직 출차 요청 안 함)
    final bool shouldShowExitButton = reservation.status == ReservationStatus.confirmed &&
        (reservation.expectedExit == null || reservation.expectedExit!.trim().isEmpty);

    print('🔍 [예약 상세] shouldShowExitButton: $shouldShowExitButton');

    return Scaffold(
      appBar: AppBar(
        title: '예약 상세'.text.size(18).bold.make(),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // background
              VxBox()
                  .height(height * 0.21)
                  .gradientFromTo(
                    from: statusInfo['colorFrom'] as Color,
                    to: statusInfo['colorTo'] as Color,
                    stops: [0.2, 0.9],
                  )
                  .make(),

              // content
              VStack([
                // status
                _buildStatus(height, statusInfo, currentStep),

                // parking lot info
                _buildParkingLotInfo(reservation),
                16.heightBox,

                // reservation info
                _buildReservationInfo(reservation),
                16.heightBox,

                // 기사 정보 (승인/확정됨일 때만 표시)
                if (reservation.handledByStaffName != null)
                  _buildDriverInfo(
                    reservation.handledByStaffName!,
                    reservation.handledByStaffPhone,
                    reservation.profileImageUrl,
                  ),
                if (reservation.handledByStaffName != null)
                  16.heightBox,

                // 메모 (있을 때만 표시)
                if (reservation.notes != null &&
                    reservation.notes!.isNotEmpty)
                  _buildMemoSection(reservation),
                if (reservation.notes != null &&
                    reservation.notes!.isNotEmpty)
                  16.heightBox,

                // 가격 정보는 일단 제거 (실제 데이터 없음)
                // _buildPrice(),
                // 16.heightBox,

                // 출차 요청 버튼 (입차 완료 상태이고 출차 예정 시간이 없을 때만 표시)
                if (shouldShowExitButton) ...[
                  _buildExitRequestButton(reservation),
                  16.heightBox,
                ] else
                  16.heightBox,

                // 출차 대기 안내 (출차 요청 상태일 때 표시)
                if (reservation.status == ReservationStatus.exitRequested)
                  _buildExitWaitingInfo(),
                if (reservation.status == ReservationStatus.exitRequested)
                  16.heightBox,

                // 취소 버튼 (pending 상태일 때만 표시)
                if (reservation.status == ReservationStatus.pending) ...[
                  _buildCancelButton(reservation),
                  16.heightBox,
                ] else
                  // 취소 버튼이 없을 때도 동일한 하단 여백 유지
                  16.heightBox,
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(double height, Map<String, dynamic> statusInfo, int currentStep) {
    return VStack([
      (height * 0.03).heightBox,
      //
      Icon(statusInfo['icon'] as IconData, size: height * 0.04, color: Colors.white)
          .centered()
          .p8()
          .box
          .roundedFull
          .color(Colors.white.withAlpha(40))
          .make(),
      (height * 0.01).heightBox,
      (statusInfo['title'] as String).text.white.size(22).bold.makeCentered(),
      if (statusInfo['subtitle'] != null && (statusInfo['subtitle'] as String).isNotEmpty)
        (statusInfo['subtitle'] as String).text.color(Colors.grey.shade50).size(16).makeCentered(),

      HStack([
            _buildStatusComponent('예약완료', currentStep),
            _buildStatusComponent('승인', currentStep),
            _buildStatusComponent('입차', currentStep),
            _buildStatusComponent('출차', currentStep),
          ], alignment: MainAxisAlignment.spaceBetween)
          .centered()
          .p12()
          .box
          .rounded
          .white
          .border(color: Colors.grey.shade300)
          .shadowSm
          .make()
          .pSymmetric(h: 16, v: 16),
    ], alignment: MainAxisAlignment.spaceEvenly);
  }

  Widget _buildStatusComponent(String title, int currentStatus) {
    bool isCurrent = false;
    bool isCompleted = false;

    if (title == '예약완료') {
      if (currentStatus == 0) {
        isCurrent = true;
      } else if (currentStatus > 0) {
        isCompleted = true;
      }
    } else if (title == '승인') {
      if (currentStatus == 1) {
        isCurrent = true;
      } else if (currentStatus > 1) {
        isCompleted = true;
      }
    } else if (title == '입차') {
      if (currentStatus == 2) {
        isCurrent = true;
      } else if (currentStatus > 2) {
        isCompleted = true;
      }
    } else if (title == '출차') {
      if (currentStatus == 3) {
        isCurrent = true;
      } else if (currentStatus > 3) {
        isCompleted = true;
      }
    }

    return VStack([
      // 원 부분 - 모든 상태에 동일한 크기 컨테이너 적용
      SizedBox(
        width: 18 * 3.0,
        height: 18 * 3.0,
        child: isCurrent
            ? RippleCircle(size: 18, color: Vx.green500)
            : Center(
                child: VxBox().roundedFull
                    .size(18, 18)
                    .color(isCompleted ? Vx.green500 : Colors.grey.shade300)
                    .make(),
              ),
      ),
      2.heightBox,
      // 텍스트 부분
      title.text
          .size(10)
          .color(
            isCurrent
                ? Vx.green500
                : isCompleted
                ? Vx.black
                : Colors.grey.shade500,
          )
          .fontWeight(
            isCurrent || isCompleted ? FontWeight.w600 : FontWeight.w300,
          )
          .make(),
    ], crossAlignment: CrossAxisAlignment.center);
  }

  Widget _buildParkingLotInfo(Reservation reservation) {

    // 예약에 위치 정보가 있으면 그걸 사용, 없으면 parkingLotsProvider에서 조회
    final parkingLotsAsync = ref.watch(parkingLotsProvider);

    // 위치 정보 결정
    double? lat = reservation.parkingLotLat;
    double? lng = reservation.parkingLotLng;

    // 예약에 위치 정보가 없으면 주차장 리스트에서 찾기
    if (lat == null || lng == null) {
      if (parkingLotsAsync.hasValue && parkingLotsAsync.value != null) {
        try {
          final parkingLot = parkingLotsAsync.value!.firstWhere(
            (lot) => lot.id == reservation.parkingLotId,
          );
          lat = parkingLot.lat;
          lng = parkingLot.lng;
        } catch (e) {
          // 주차장을 못 찾으면 그냥 null로 둠
        }
      }
    }

    final hasLocation = lat != null && lng != null;

    return VStack([
          // info
          HStack([
            // Image

            // Info
            Expanded(
              child: VStack([
                (reservation.parkingLotName ?? '주차장').text.size(18).bold.make(),
                // 주소와 전화번호는 reservation에 없으므로 제거 또는 임시 표시
              ]).p(16),
            ),
          ]).box.topRounded().white.make(),
          VxBox().height(1).color(Colors.grey.shade300).make(),
          // direction
          HStack([
                Icon(
                  Icons.navigation_outlined,
                  size: 20,
                  color: hasLocation ? Colors.black87 : Colors.grey.shade400,
                ).rotate45().pOnly(bottom: 4),
                '길찾기'.text
                    .size(16)
                    .fontWeight(FontWeight.w500)
                    .color(hasLocation ? Colors.black87 : Colors.grey.shade400)
                    .makeCentered(),
              ], crossAlignment: CrossAxisAlignment.end)
              .centered()
              .p(8)
              .box
              .bottomRounded()
              .color(Colors.grey.shade100)
              .makeCentered()
              .onInkTap(hasLocation
                  ? () {
                      NavigationSelectionSheet.showWithCoords(
                        context,
                        lat: lat!,
                        lng: lng!,
                        title: reservation.parkingLotName ?? '주차장',
                      );
                    }
                  : null),
        ]).box.rounded
        .border(color: Colors.grey.shade300)
        .shadowSm
        .make()
        .pSymmetric(h: 16);
  }

  Widget _buildReservationInfo(Reservation reservation) {

    return VStack([
          '예약 정보'.text.size(18).bold.make(),
          8.heightBox,
          _buildHorizonInfo('차량 번호', reservation.visitorVehiclePlate ?? '차량번호 없음'),

          VxBox().height(1).color(Colors.grey.shade300).make().pOnly(bottom: 8),
          _buildHorizonInfo(
            '입차 ${reservation.actualArrival != null ? "완료" : "예정"}',
            _formatDateTime(reservation.actualArrival ?? reservation.expectedArrival),
          ),
          _buildHorizonInfo(
            '출차 ${reservation.actualExit != null ? "완료" : (reservation.expectedExit != null && reservation.expectedExit!.isNotEmpty) ? "예정" : "예정"}',
            reservation.actualExit != null
                ? _formatDateTime(reservation.actualExit!)
                : reservation.status == ReservationStatus.exitRequested
                    ? '출차 요청 승인 대기중'
                    : (reservation.expectedExit != null && reservation.expectedExit!.isNotEmpty)
                        ? _formatDateTime(reservation.expectedExit!)
                        : '미정',
          ),
          _buildHorizonInfo('예약 생성', _formatDateTime(reservation.createdAt), isSmall: true),
        ])
        .p(16)
        .box
        .rounded
        .white
        .border(color: Colors.grey.shade300)
        .shadowSm
        .make()
        .pSymmetric(h: 16);
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

  Widget _buildHorizonInfo(
    String title,
    String content, {
    bool isSmall = false,
  }) {
    return HStack([
      title.text.size(!isSmall ? 14 : 12).color(Colors.grey.shade500).make(),
      Spacer(),
      content.text
          .size(!isSmall ? 14 : 12)
          .fontWeight(FontWeight.w500)
          .color(Colors.black)
          .make(),
    ]).box.topRounded().white.make().pOnly(bottom: !isSmall ? 8 : 0);
  }

  Widget _buildDriverInfo(String name, String? phone, String? profileImageUrl) {
    return VStack([
          HStack([
            Icon(Icons.check_circle_outline, color: Vx.green700, size: 22),
            8.widthBox,
            '배정된 기사님'.text.size(18).color(Vx.green700).semiBold.make(),
            12.widthBox,
          ]),
          8.heightBox,

          HStack([
            // 프로필 이미지 (있으면 네트워크 이미지, 없으면 아이콘)
            profileImageUrl != null && profileImageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profileImageUrl,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: Colors.grey.shade500, size: 30)
                            .p4()
                            .box
                            .roundedFull
                            .color(Colors.white)
                            .border(color: Vx.green300)
                            .make();
                      },
                    ),
                  )
                : Icon(Icons.person, color: Colors.grey.shade500, size: 30)
                    .p4()
                    .box
                    .roundedFull
                    .color(Colors.white)
                    .border(color: Vx.green300)
                    .make(),
            12.widthBox,
            VStack([
              '$name 기사님'.text.size(18).color(Colors.black).bold.make(),
              PhoneNumberUtils.globalToKorea(phone!).text
                  .size(14)
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
        .border(color: Vx.green200)
        .shadowSm
        .make()
        .px16();
  }

  Widget _buildMemoSection(Reservation reservation) {

    return VStack([
          HStack([
            Icon(
              Icons.description_outlined,
              color: Colors.grey.shade700,
              size: 20,
            ).pOnly(bottom: 4),
            8.widthBox,
            Expanded(
              child: '메모'.text
                  .size(18)
                  .color(Colors.grey.shade700)
                  .fontWeight(FontWeight.w500)
                  .make(),
            ),
          ]),
          4.heightBox,

          (reservation.notes ?? '').text
              .size(14)
              .color(Colors.grey.shade800)
              .fontWeight(FontWeight.w500)
              .make(),
        ])
        .pSymmetric(v: 16, h: 16)
        .box
        .rounded
        .color(Colors.grey.shade50)
        .border(color: Colors.grey.shade300)
        .shadowSm
        .make()
        .pSymmetric(h: 16);
  }

  Widget _buildExitRequestButton(Reservation reservation) {
    return GestureDetector(
      onTap: () async {
        // 출차 예정 시간 선택
        final selectedDateTime = await _showExitTimePickerDialog();

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
            title: '출차 요청'.text.size(18).bold.make(),
            content: VStack([
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: '취소'.text.size(15).color(Colors.grey.shade600).make(),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: '출차 요청'.text.size(15).color(Vx.purple700).bold.make(),
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
      child: '출차 요청'.text.blue600
          .size(16)
          .bold
          .makeCentered()
          .p(12)
          .box
          .rounded
          .blue50
          .border(color: Vx.blue600, width: 2)
          .make()
          .px16(),
    );
  }

  /// 출차 시간 선택 다이얼로그
  Future<DateTime?> _showExitTimePickerDialog() async {
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

  Widget _buildExitWaitingInfo() {
    return VStack([
          HStack([
            Icon(Icons.schedule, color: Vx.purple600, size: 22),
            8.widthBox,
            '출차 시간 승인 대기 중'.text.size(18).color(Vx.purple600).semiBold.make(),
          ]),
          8.heightBox,
          '기사님께서 승인 후 출차 시간이 확정됩니다.'
              .text
              .size(14)
              .color(Colors.grey.shade700)
              .make(),
        ])
        .pSymmetric(v: 16, h: 16)
        .box
        .rounded
        .purple50
        .border(color: Vx.purple200)
        .shadowSm
        .make()
        .px16();
  }

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('예약이 취소되었습니다')),
                );
                // 이전 화면으로 돌아가기
                Navigator.pop(context);
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('취소 실패: $e')),
              );
            }
          }
        }
      },
      child: '예약 취소'.text.red600
          .size(16)
          .bold
          .makeCentered()
          .p(12)
          .box
          .rounded
          .red50
          .border(color: Vx.red600, width: 2)
          .make()
          .px16(),
    );
  }
}
