import 'package:daeja/core/constants/colors.dart';
import 'package:daeja/core/services/phone_call_service.dart';
import 'package:daeja/core/services/price_service.dart';
import 'package:daeja/features/parking/domain/models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/phone_number_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../parking/presentation/providers/parking_providers.dart';
import '../../../parking/presentation/widgets/navigation_selection_sheet.dart';
import '../../domain/models/reservation.dart';
import '../providers/user_reservation_provider.dart';

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
  String _getStatusInfo(Reservation reservation) {
    final status = reservation.status;

    switch (status) {
      case ReservationStatus.pending:
        return '예약완료';
      case ReservationStatus.approved:
        return '승인됨';
      case ReservationStatus.confirmed:
        return '입차됨';
      case ReservationStatus.exitRequested:
        return '출차요청';
      case ReservationStatus.completed:
        return '이용완료';
      case ReservationStatus.cancelled:
        return '취소됨';
    }
  }

  // 현재 진행 단계 계산 (0: 예약완료, 1: 승인, 2: 입차, 3: 출차)
  int _getCurrentStep(Reservation reservation) {
    print('🔍 [_getCurrentStep] status: ${reservation.status}');
    print('🔍 [_getCurrentStep] actualArrival: ${reservation.actualArrival}');
    print('🔍 [_getCurrentStep] actualExit: ${reservation.actualExit}');

    // status를 우선하여 판단 (status가 진실의 원천)
    return switch (reservation.status) {
      // 취소됨
      ReservationStatus.cancelled => -1,

      // 출차 완료
      ReservationStatus.completed => 3,

      // 출차 요청됨 또는 입차 완료
      ReservationStatus.exitRequested => 2,
      ReservationStatus.confirmed => 2,

      // 승인됨
      ReservationStatus.approved => 1,

      // 대기중
      ReservationStatus.pending => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    Log.d('ReservationID: ${widget.reservationId}');
    Log.d('Reservation: ${widget.reservation}');
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
              body: Center(child: '예약을 찾을 수 없습니다.'.text.size(16).make()),
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
          body: Center(child: '예약 정보를 불러올 수 없습니다.'.text.size(16).make()),
        ),
      );
    }

    // reservation 객체가 직접 제공된 경우
    return _buildNormalContent(context, height, widget.reservation!);
  }

  Widget _buildNormalContent(
    BuildContext context,
    double height,
    Reservation reservation,
  ) {
    final statusInfo = _getStatusInfo(reservation);
    final currentStep = _getCurrentStep(reservation);

    // 디버깅: 출차 관련 데이터 확인
    print('🔍 [예약 상세] status: ${reservation.status}');
    print('🔍 [예약 상세] expectedExit: ${reservation.expectedExit}');
    print('🔍 [예약 상세] actualExit: ${reservation.actualExit}');
    print(
      '🔍 [예약 상세] expectedExit == null: ${reservation.expectedExit == null}',
    );
    print(
      '🔍 [예약 상세] expectedExit.isEmpty: ${reservation.expectedExit?.isEmpty}',
    );
    print('🔍 [예약 상세] ㄱㅣㅅㅏㄴㅣㅁ ㅇㅣㅁㅣㅈㅣ: ${reservation.handledByStaffProfileUrl}');

    // 출차 요청 버튼 표시 여부 (입차 완료이고 아직 출차 요청 안 함)
    final bool shouldShowExitButton =
        reservation.status == ReservationStatus.confirmed &&
        (reservation.expectedExit == null ||
            reservation.expectedExit!.trim().isEmpty);

    print('🔍 [예약 상세] shouldShowExitButton: $shouldShowExitButton');

    return Scaffold(
      appBar: AppBar(
        title: '예약 상세'.text.size(18).bold.make(),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: const Color(0xFF3478F7)),
      ),
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          // content
          child: VStack([
            // status
            _buildStatus(height, statusInfo, currentStep),

            // 출차 대기 안내 (출차 요청 상태일 때 표시)
            if (reservation.status == ReservationStatus.exitRequested) ...[
              16.heightBox,
              _buildExitWaitingInfo(),
            ],

            // car info
            _buildCarInfo(reservation),

            // 기사 정보 (승인/확정됨일 때만 표시)
            if (reservation.handledByStaffName != null)
              _buildDriverInfo(
                reservation.handledByStaffName!,
                reservation.handledByStaffPhone,
                reservation.handledByStaffProfileUrl,
              ),
            if (reservation.handledByStaffName != null) 16.heightBox,

            // reservation info
            _buildReservationInfo(reservation),
            16.heightBox,

            // parking lot info
            _buildParkingLotInfo(reservation),
            16.heightBox,

            _buildMeetingPointInfo(reservation),
            16.heightBox,

            // 메모 (있을 때만 표시)
            if (reservation.notes != null && reservation.notes!.isNotEmpty)
              _buildMemoSection(reservation),
            if (reservation.notes != null && reservation.notes!.isNotEmpty)
              16.heightBox,

            // 가격 정보
            _buildPrice(reservation),
            16.heightBox,

            // 출차 요청 버튼 (입차 완료 상태이고 출차 예정 시간이 없을 때만 표시)
            if (shouldShowExitButton) ...[
              _buildExitRequestButton(reservation),
              16.heightBox,
            ],

            // 취소 버튼 (pending 상태일 때만 표시)
            if (reservation.status == ReservationStatus.pending) ...[
              _buildCancelButton(reservation),
              16.heightBox,
            ] else
              // 취소 버튼이 없을 때도 동일한 하단 여백 유지
              16.heightBox,
          ]),
        ),
      ),
    );
  }

  Widget _buildStatus(double height, String statusInfo, int currentStep) {
    return VStack([
      (height * 0.01).heightBox,
      '현재 상태'.text.color(Colors.grey.shade600).size(14).semiBold.make(),
      statusInfo.text.color(mainColor).size(22).bold.make(),

      HStack(
            [
              _buildStatusComponent('예약완료', currentStep),
              _buildStatusComponent('승인됨', currentStep),
              _buildStatusComponent('입차됨', currentStep),
              _buildStatusComponent('출차됨', currentStep),
            ],
            alignment: MainAxisAlignment.spaceEvenly,
            axisSize: MainAxisSize.max,
          )
          .centered()
          // .p12()
          .box
          .white
          .make()
          .pSymmetric(h: 4, v: 4),
    ], alignment: MainAxisAlignment.spaceEvenly).p16().box.white.make();
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
    } else if (title == '승인됨') {
      if (currentStatus == 1) {
        isCurrent = true;
      } else if (currentStatus > 1) {
        isCompleted = true;
      }
    } else if (title == '입차됨') {
      if (currentStatus == 2) {
        isCurrent = true;
      } else if (currentStatus > 2) {
        isCompleted = true;
      }
    } else if (title == '출차됨') {
      if (currentStatus == 3) {
        isCurrent = true;
      } else if (currentStatus > 3) {
        isCompleted = true;
      }
    }

    return VStack([
      // 원 부분 - 모든 상태에 동일한 크기 컨테이너 적용
      SizedBox(
        width: 20 * 3.0,
        height: 12 * 3.0,
        child: Center(
          child: VxBox().roundedFull
              .size(18, 18)
              .color(
                isCompleted || isCurrent ? mainColor : Colors.grey.shade300,
              )
              .withShadow([
                BoxShadow(
                  color: isCurrent ? mainColor : Vx.white,
                  blurRadius: 4,
                ),
              ])
              .make(),
        ),
      ),
      2.heightBox,
      // 텍스트 부분
      title.text
          .size(10)
          .color(isCompleted || isCurrent ? mainColor : Colors.grey.shade500)
          .fontWeight(
            isCurrent || isCompleted ? FontWeight.w600 : FontWeight.w300,
          )
          .make(),
    ], crossAlignment: CrossAxisAlignment.center);
  }

  Widget _buildParkingLotInfo(Reservation reservation) {
    // 주차장 상세 정보를 가져오기 위한 provider watch
    final parkingLotsAsync = ref.watch(parkingLotsProvider);
    String? tel;
    double? lat;
    double? lng;

    // 데이터 매칭 (전화번호와 위치 정보를 가져오기 위함)
    if (parkingLotsAsync.hasValue) {
      try {
        final lot = parkingLotsAsync.value!.firstWhere(
          (l) => l.id == reservation.parkingLotId,
        );
        tel = lot.tel; // 주차장 전화번호
        lat = lot.lat;
        lng = lot.lng;
      } catch (_) {}
    }

    return HStack([
          // 1. 왼쪽: 주차장 정보 텍스트
          VStack([
            HStack([
              Icon(
                Icons.local_parking,
                color: mainColor,
                size: 24,
              ).pOnly(bottom: 4),
              8.widthBox,
              '이용중인 주차장'.text
                  .color(Colors.grey.shade600)
                  .size(15)
                  .semiBold
                  .make(),
            ], crossAlignment: CrossAxisAlignment.start),
            4.heightBox,
            (reservation.parkingLotName ?? '주차장').text
                .size(18)
                .extraBold
                .make(),
          ]).expand(), // 텍스트 영역이 남은 공간을 다 채우도록 expand
          // 2. 오른쪽: 액션 버튼들 (전화, 길찾기)
          HStack([
            // 전화 버튼
            if (tel != null)
              Icon(Icons.navigation_rounded, color: mainColor, size: 22)
                  .p12()
                  .box
                  .roundedFull
                  .color(mainColor.withOpacity(0.1))
                  .make()
                  .onInkTap(() {
                    NavigationSelectionSheet.showWithCoords(
                      context,
                      lat: lat!,
                      lng: lng!,
                      title: reservation.parkingLotName ?? '주차장',
                    );
                  }),

            8.widthBox,

            // 길찾기 버튼
            if (lat != null && lng != null)
              Icon(
                Icons.phone,
                color: Colors.white,
                size: 22,
              ).p12().box.roundedFull.color(mainColor).make().onInkTap(() {
                PhoneCallService.callTo(tel!);
              }),
          ]),
        ])
        .wFull(context)
        .p(16)
        .box
        .rounded
        .white
        .border(color: Colors.grey.shade300)
        .make()
        .px16();
  }

  Widget _buildMeetingPointInfo(Reservation reservation) {
    // 주차장 정보에서 미팅 포인트 가져오기
    final parkingLotsAsync = ref.watch(parkingLotsProvider);

    double? meetingLat;
    double? meetingLon;
    String? meetingPoint;
    String? meetingGuide;

    if (parkingLotsAsync.hasValue && parkingLotsAsync.value != null) {
      try {
        final parkingLot = parkingLotsAsync.value!.firstWhere(
          (lot) => lot.id == reservation.parkingLotId,
        );
        meetingLat = parkingLot.meetingLat;
        meetingLon = parkingLot.meetingLon;
        meetingPoint = parkingLot.meetingPoint;
        meetingGuide = parkingLot.meetingGuide;
      } catch (e) {
        // 주차장을 못 찾으면 null
      }
    }

    // 미팅 포인트 정보가 없으면 표시하지 않음
    if (meetingPoint == null && meetingLat == null) {
      return SizedBox.shrink();
    }

    final hasLocation = meetingLat != null && meetingLon != null;

    return VStack([
          HStack([
            Icon(
              Icons.location_on,
              color: mainColor,
              size: 24,
            ).pOnly(bottom: 4),
            8.widthBox,
            '차량 인수 위치'.text
                .color(Colors.grey.shade600)
                .size(15)
                .semiBold
                .make(),
          ], crossAlignment: CrossAxisAlignment.start),
          8.heightBox,

          // 미팅 포인트 설명
          if (meetingPoint != null)
            (meetingPoint).text.size(18).extraBold.make(),
          if (meetingPoint != null) 8.heightBox,

          // 미팅 가이드
          if (meetingGuide != null)
            HStack([
              Icon(Icons.info_outline, size: 16, color: errorColor),
              4.widthBox,
              Expanded(
                child: (meetingGuide).text.size(14).color(errorColor).make(),
              ),
            ]),
          if (meetingGuide != null) 12.heightBox,

          // 길찾기 버튼
          if (hasLocation)
            HStack([
                  Icon(
                    Icons.navigation,
                    size: 20,
                    color: Colors.white,
                  ).rotate45().pOnly(bottom: 4),
                  4.widthBox,
                  '길찾기'.text
                      .size(16)
                      .fontWeight(FontWeight.w500)
                      .white
                      .makeCentered(),
                ], crossAlignment: CrossAxisAlignment.end)
                .centered()
                .p8()
                .box
                .rounded
                .color(mainColor)
                .makeCentered()
                .onInkTap(() {
                  NavigationSelectionSheet.showWithCoords(
                    context,
                    lat: meetingLat!,
                    lng: meetingLon!,
                    title: meetingPoint ?? '미팅 위치',
                  );
                }),
        ])
        .wFull(context)
        .p(16)
        .box
        .rounded
        .white
        .border(color: Colors.grey.shade300)
        .make()
        .px16();
  }

  Widget _buildReservationInfo(Reservation reservation) {
    return VStack([
      // Title
      HStack([
        Icon(Icons.access_time_filled_rounded, color: mainColor, size: 18),
        8.widthBox,
        '예약 정보'.text.size(16).bold.make(),
      ]),

      8.heightBox,

      VxBox().height(1).color(Colors.grey.shade300).make().pOnly(bottom: 8),
      _buildHorizonInfo('예약 생성', _formatDateTime(reservation.createdAt)),
      _buildHorizonInfo(
        '입차 ${reservation.actualArrival != null ? "완료" : "예정"}',
        _formatDateTime(
          reservation.actualArrival ?? reservation.expectedArrival,
        ),
        isEnd: reservation.actualArrival != null ? true : false,
      ),
      _buildHorizonInfo(
        '출차 ${reservation.actualExit != null
            ? "완료"
            : (reservation.expectedExit != null && reservation.expectedExit!.isNotEmpty)
            ? "예정"
            : "예정"}',
        reservation.actualExit != null
            ? _formatDateTime(reservation.actualExit!)
            : reservation.status == ReservationStatus.exitRequested
            ? '출차 요청 승인 대기중'
            : (reservation.expectedExit != null &&
                  reservation.expectedExit!.isNotEmpty)
            ? _formatDateTime(reservation.expectedExit!)
            : '미정',
        isEnd: reservation.actualExit != null ? true : false,
      ),
    ]).p(16).box.white.make();
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

  Widget _buildHorizonInfo(String title, String content, {bool isEnd = false}) {
    return HStack([
      title.text.size(14).color(Colors.grey.shade500).semiBold.make(),
      Spacer(),
      content.text.size(14).bold.color(isEnd ? mainColor : Colors.black).make(),
    ]).box.topRounded().white.make().pOnly(bottom: 8);
  }

  Widget _buildDriverInfo(String name, String? phone, String? profileImageUrl) {
    return HStack([
          profileImageUrl != null && profileImageUrl.isNotEmpty
              ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            "❌ 재시도 에러: $error \n URL: $profileImageUrl",
                          );
                          return _buildDefaultIcon();
                        },
                      ),
                    ).box.roundedFull
                    .color(Colors.white)
                    .border(color: Colors.white, width: 1.5)
                    .make()
              : _buildDefaultIcon(),
          12.widthBox,
          VStack([
            '배정된 기사님'.text
                .size(14)
                .color(Colors.grey.shade600)
                .fontWeight(FontWeight.w400)
                .make(),
            '$name 기사님'.text.size(18).color(Colors.black).bold.make(),
          ]),
          Spacer(),

          Icon(
            Icons.call,
            color: Colors.white,
            size: 22,
          ).p12().box.roundedFull.color(mainColor).make().onTap(() {
            if (phone != null) {
              PhoneCallService.callTo(PhoneNumberUtils.globalToKorea(phone));
            }
          }),
        ])
        .p16()
        .box
        .rounded
        .color(mainColor.withOpacity(0.1))
        .border(color: mainColor)
        .make()
        .px16();
  }

  // 아이콘 빌더 공통화
  Widget _buildDefaultIcon() {
    return Icon(Icons.person, color: Colors.grey.shade500, size: 30)
        .p4()
        .box
        .roundedFull
        .color(Colors.white)
        .border(color: Colors.white, width: 1.5)
        .make();
  }

  Widget _buildMemoSection(Reservation reservation) {
    return VStack([
          HStack([
            Icon(
              Icons.description_outlined,
              color: mainColor,
              size: 24,
            ).pOnly(bottom: 4),
            8.widthBox,
            Expanded(
              child: '요청사항'.text
                  .color(Colors.grey.shade600)
                  .size(15)
                  .semiBold
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
        .white
        .border(color: Colors.grey.shade300)
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
            title: Text(
              '출차 요청',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('출차를 요청하시겠습니까?', style: TextStyle(fontSize: 15)),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '출차 예정 시간',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDateTime(selectedDateTime.toIso8601String()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '기사님께서 승인 후 출차 시간이 확정됩니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  '취소',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  '출차 요청',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          try {
            // 로딩 표시
            Dialogs.showProgressBar(context);

            final controller = ref.read(userReservationControllerProvider);
            final currentUser = ref.read(currentAuthUserProvider);

            if (currentUser != null) {
              await controller.requestExit(
                reservation.id,
                currentUser.uid,
                selectedDateTime,
              );

              // 로딩 닫기 및 성공 피드백
              if (mounted) {
                Navigator.of(context).pop(); // Progress bar 닫기
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('출차 요청이 접수되었습니다')));
              }
            } else {
              if (mounted) Navigator.of(context).pop(); // Progress bar 닫기
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pop(); // Progress bar 닫기
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('출차 요청 실패: $e')));
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
            const Icon(
              Icons.pending_actions_rounded,
              color: mainColor,
              size: 24,
            ).pOnly(bottom: 4),
            8.widthBox,
            '출차 승인 대기 중'.text.color(mainColor).size(15).semiBold.make(),
          ], crossAlignment: CrossAxisAlignment.start),
          8.heightBox,

          // 상세 가이드
          '기사님께서 확인 후 출차 시간이 최종 확정됩니다. 잠시만 기다려 주세요.'.text
              .size(14)
              .color(Colors.grey.shade700)
              .make(),
        ])
        .wFull(context)
        .p(16)
        .box
        .rounded
        .color(mainColor.withOpacity(0.05)) // 배경색에 살짝 보라색 힌트
        .border(color: mainColor.withOpacity(0.1)) // 테두리도 보라색 계열로 통일
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('예약이 취소되었습니다')));
                // 이전 화면으로 돌아가기
                Navigator.pop(context);
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

  Widget _buildCarInfo(Reservation reservation) {
    // 차량 모델명 표시 (제조사 + 모델)
    final vehicleModel = [
      reservation.visitorVehicleManufacturer,
      reservation.visitorVehicleModel,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    return HStack([
          // Info
          VStack([
            // 차량 모델명
            (vehicleModel.isNotEmpty ? vehicleModel : '차량 정보').text
                .size(20)
                .bold
                .color(Colors.black87)
                .make(),
            4.heightBox,

            // 차량 번호판
            (reservation.visitorVehiclePlate ?? '차량번호 없음').text
                .size(15)
                .fontWeight(FontWeight.w700)
                .letterSpacing(2)
                .color(mainColor)
                .make()
                .pSymmetric(v: 6, h: 10)
                .box
                .roundedSM
                .color(mainColor.withOpacity(0.1))
                .make(),
          ]).expand(),

          // Image
          Image.asset(
            'assets/images/cars/sedan.png',
            width: 66,
            height: 46,
            fit: BoxFit.cover,
          ),
        ])
        .p20()
        .box
        .rounded
        .white
        .border(color: Colors.grey.shade300)
        .make()
        .wFull(context)
        .px16()
        .py(8);
  }

  Widget _buildPrice(Reservation reservation) {
    // 요금 정보가 없으면 섹션 숨김
    if (reservation.valetFee == null || reservation.dailyParkingFee == null) {
      return SizedBox.shrink();
    }

    // 출차 시간이 없으면 계산 불가
    if (reservation.expectedExit == null) {
      return SizedBox.shrink();
    }

    try {
      // 날짜 파싱
      final arrivalTime = DateTime.parse(reservation.expectedArrival);
      final exitTime = DateTime.parse(reservation.expectedExit!);

      final valetFee = reservation.valetFee!;
      final dailyParkingFee = reservation.dailyParkingFee!;

      // PriceService로 계산
      final daysDifference = PriceService.calculateDays(arrivalTime, exitTime);
      final parkingFee = PriceService.calculateParkingFee(
        arrivalTime,
        exitTime,
        dailyParkingFee,
      );
      final totalFee = PriceService.calculateTotalFee(
        arrivalTime,
        exitTime,
        valetFee,
        dailyParkingFee,
      );

      // UI 표시
      return VStack([
            // 발렛 요금
            HStack([
              '발렛 요금'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
              Spacer(),
              PriceService.formatCurrency(
                valetFee,
              ).text.color(Colors.grey.shade400).size(15).semiBold.make(),
            ]),

            // 주차 요금 (일수 표시)
            HStack([
              '주차 요금 ($daysDifference일)'.text
                  .color(Colors.grey.shade600)
                  .size(15)
                  .semiBold
                  .make(),
              Spacer(),
              PriceService.formatCurrency(
                parkingFee,
              ).text.color(Colors.grey.shade400).size(15).semiBold.make(),
            ]),
            4.heightBox,

            // 전체 요금
            HStack([
              '전체 요금'.text.color(Colors.black87).size(18).semiBold.make(),
              Spacer(),
              PriceService.formatCurrency(
                totalFee,
              ).text.color(mainColor).size(22).bold.make(),
            ]),
            12.heightBox,

            Divider(),

            '요금 결제를 위한 계좌'.text
                .color(Colors.grey.shade600)
                .size(12)
                .bold
                .make(),
            4.heightBox,

            HStack([
                  '농협 351-1339-5934-63 이재석'.text
                      .color(Colors.black54)
                      .bold
                      .make()
                      .expand(),
                  Icon(Icons.copy, size: 20)
                      .p8()
                      .box
                      .white
                      .rounded
                      .border(color: Colors.grey.shade100)
                      .make()
                      .onInkTap(() {
                        // 클립보드에 텍스트 복사
                        Clipboard.setData(
                          const ClipboardData(text: "농협 351-1339-5934-63 이재석"),
                        );

                        // 사용자에게 알림 표시 (선택 사항이지만 권장)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("계좌번호가 복사되었습니다.")),
                        );
                      }),
                ])
                .p16()
                .wFull(context)
                .box
                .rounded
                .color(Colors.grey.shade50)
                .make(),
          ])
          .p16()
          .wFull(context)
          .box
          .rounded
          .white
          .border(color: Colors.grey.shade300)
          .make()
          .px16();
    } catch (e) {
      // 날짜 파싱 실패 시 섹션 숨김
      return SizedBox.shrink();
    }
  }
}
