import 'package:daeja/core/constants/colors.dart';
import 'package:daeja/core/services/phone_call_service.dart';
import 'package:daeja/core/services/vehicle_image_service.dart';
import 'package:daeja/features/reservation/presentation/screens/reservation_complete_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/services/price_service.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../parking/domain/models/parking_lot.dart';
import '../../../parking/presentation/widgets/navigation_selection_sheet.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../user/domain/models/vehicle.dart';
import '../../../user/presentation/screens/vehicle_add_screen.dart';
import '../providers/user_reservation_provider.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  final ParkingLot parkingLot;

  const ReservationScreen({super.key, required this.parkingLot});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  late DateTime selectedArrivalTime;
  DateTime? selectedExitTime;
  String? selectedVehicleId;
  bool isSubmitting = false;
  final TextEditingController _requestController = TextEditingController();
  final GlobalKey<TooltipState> _exitTimeTooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    selectedArrivalTime = DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final vehicles = ref.watch(userVehiclesProvider);

    // 차량 목록 로드 시 첫 번째 차량 자동 선택
    if (selectedVehicleId == null && vehicles != null && vehicles.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => selectedVehicleId = vehicles.first.id);
      });
    }

    // 로그인 체크
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: '발렛 예약'.text.size(18).bold.make(),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: VStack([
            // 아이콘
            Icon(Icons.lock_outlined, size: 80, color: Colors.grey.shade400),
            24.heightBox,

            // 메시지
            '로그인이 필요합니다'.text.size(20).bold.color(Colors.black87).make(),
            12.heightBox,
            '발렛 예약을 하려면\n로그인이 필요합니다'.text
                .size(14)
                .color(Colors.grey.shade600)
                .center
                .make(),
            32.heightBox,

            // 로그인 버튼
            HStack([
                  Icon(Icons.login, color: Colors.white, size: 20),
                  8.widthBox,
                  '로그인하기'.text.white.bold.size(16).make(),
                ])
                .centered()
                .p16()
                .box
                .blue600
                .roundedLg
                .make()
                .onInkTap(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                })
                .w(200),
          ], crossAlignment: CrossAxisAlignment.center).p20(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: '발렛 예약'.text.size(18).bold.make(),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: VStack([
            _buildParkingLotHeader(),
            24.heightBox,
            _buildMeetingPointInfo(),
            24.heightBox,
            _buildVehicleSelector(vehicles),
            16.heightBox,
            _buildScheduleSection(),
            16.heightBox,
            _buildReservationNotice(),
            24.heightBox,
            _buildRequestSection(),
            16.heightBox,
            _buildPrice(),
            16.heightBox,
            _buildSubmitButton(currentUser.uid),
          ]).p20().scrollVertical(),
        ),
      ),
    );
  }

  /// 주차장 이름 + 주소 헤더
  Widget _buildParkingLotHeader() {
    return HStack([
      VStack([
        widget.parkingLot.name.text.size(20).bold.make(),
        widget.parkingLot.address.text.size(14).gray600.make(),
      ]),
      Spacer(),
      const Icon(Icons.call, size: 26, color: mainColor)
          .p(10)
          .box
          .roundedFull
          .color(mainColor.withOpacity(0.15))
          .makeCentered()
          .onTap(
            () => PhoneCallService.callTo(widget.parkingLot.tel.toString()),
          ),
    ], crossAlignment: CrossAxisAlignment.center);
  }

  /// 주차장에서 제공하는 예약 안내 문구 (없으면 빈 위젯)
  Widget _buildReservationNotice() {
    if (widget.parkingLot.reservationInfo == null ||
        widget.parkingLot.reservationInfo!.isEmpty) {
      return const SizedBox.shrink();
    }
    return VStack([
      '예약 안내'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
      8.heightBox,
      widget.parkingLot.reservationInfo!.text
          .size(14)
          .color(Colors.grey.shade700)
          .make()
          .p16()
          .box
          .rounded
          .color(mainColor.withOpacity(0.1))
          .border(color: mainColor.withOpacity(0.2))
          .make(),
    ]);
  }

  /// 도착 / 출차 예정 시간 선택
  Widget _buildScheduleSection() {
    return HStack([
      // 입차
      VStack([
        '입차 시간'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
        4.heightBox,
        HStack([
              Icon(Icons.login_outlined, size: 24, color: mainColor),
              8.widthBox,
              VStack([
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _formatDate(
                    selectedArrivalTime,
                  ).text.size(14).semiBold.color(Colors.grey.shade600).make(),
                ),
                _formatTime(
                  selectedArrivalTime,
                ).text.size(22).bold.color(Colors.black).make(),
              ]).expand(),
            ])
            .h(64)
            .p16()
            .box
            .rounded
            .white
            .border(color: Colors.grey.shade100)
            .make()
            .wFull(context)
            .onInkTap(() => _selectArrivalDateTime()),
      ]).expand(),
      12.widthBox,

      // 출차
      VStack([
        HStack([
          '출차 시간'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
          4.widthBox,
          Tooltip(
            key: _exitTimeTooltipKey,
            message: '출차 시간을 선택하지 않으면\n예약 내역에서 출차 요청을 할 수 있습니다.',
            triggerMode: TooltipTriggerMode.manual,
            showDuration: const Duration(seconds: 3),
            child: GestureDetector(
              onTap: () =>
                  _exitTimeTooltipKey.currentState?.ensureTooltipVisible(),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ]),
        4.heightBox,
        HStack([
              Icon(
                Icons.logout_outlined,
                size: 24,
                color: selectedExitTime != null ? mainColor : Colors.grey.shade400,
              ),
              8.widthBox,
              VStack([
                if (selectedExitTime != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _formatDate(
                      selectedExitTime!,
                    ).text.size(14).semiBold.color(Colors.grey.shade600).make(),
                  )
                else
                  const SizedBox.shrink(),
                (selectedExitTime != null
                        ? _formatTime(selectedExitTime!)
                        : '시간 선택')
                    .text
                    .size(22)
                    .bold
                    .color(
                      selectedExitTime != null
                          ? Colors.black
                          : Colors.grey.shade400,
                    )
                    .make(),
              ]).expand(),
            ])
            .h(64)
            .p16()
            .box
            .rounded
            .white
            .border(color: Colors.grey.shade100)
            .make()
            .wFull(context)
            .onInkTap(() => _selectExitDateTime()),
      ]).expand(),
    ]);
  }

  /// 주차장 사장님께 전달할 요청 사항 입력
  Widget _buildRequestSection() {
    return VStack([
      '요청 사항'.text.color(Colors.grey.shade600).size(15).semiBold.make(),

      12.heightBox,
      Stack(
        children: [
          TextField(
            controller: _requestController,
            maxLines: 2,
            maxLength: 200,
            cursorColor: mainColor,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: '주차장 사장님께 전달할 메세지가 있다면 남겨주세요',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: mainColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // 글자 수 카운터
          Positioned(
            right: 12,
            bottom: 12,
            child: Text(
              '${_requestController.text.length}/200',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    ]);
  }

  /// 예상 결제금액 + 예약 신청 버튼
  Widget _buildSubmitButton(String userId) {
    return (isSubmitting
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ).h(20).w(20)
            : '예약 신청하기'.text.white.bold.size(16).make())
        .centered()
        .p16()
        .box
        .color(
          selectedVehicleId != null && !isSubmitting
              ? Colors.black
              : Colors.grey.shade400,
        )
        .rounded
        .make()
        .onInkTap(
          selectedVehicleId != null && !isSubmitting
              ? () => _submitReservation(userId)
              : null,
        )
        .wFull(context);
  }

  Future<void> _submitReservation(String userId) async {
    int? fee = _calculateEstimatedFee();

    if (selectedVehicleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('차량을 선택해주세요')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final controller = ref.read(userReservationControllerProvider);
      final user = ref.read(userProvider);

      // 선택된 차량 정보 찾기
      final selectedVehicle = user.value?.vehicles?.firstWhere(
        (v) => v.id == selectedVehicleId,
      );

      await controller.createReservation(
        userId: userId,
        vehicleId: selectedVehicleId!,
        parkingLotId: widget.parkingLot.id,
        expectedArrival: selectedArrivalTime,
        expectedExit: selectedExitTime,
        notes: _requestController.text.trim().isEmpty
            ? null
            : _requestController.text.trim(),
        vehiclePlate: selectedVehicle?.plateNumber,
        vehicleManufacturer: selectedVehicle?.manufacturer,
        vehicleModel: selectedVehicle?.model,
        parkingLotName: widget.parkingLot.name,
        parkingLotLat: widget.parkingLot.lat,
        parkingLotLng: widget.parkingLot.lng,
        valetFee: widget.parkingLot.basePrice,
        dailyParkingFee: widget.parkingLot.unitPrice,
      );

      if (mounted) {
        _showSuccessScreen(
          widget.parkingLot,
          selectedVehicle?.plateNumber,
          selectedArrivalTime,
          selectedExitTime,
          fee,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('예약 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showSuccessScreen(
    ParkingLot parkingLot,
    String? vehiclePlate,
    DateTime expectedArrival,
    DateTime? expectedExit,
    int? fee,
  ) {
    Navigator.pop(context); // 예약 화면 닫기
    Navigator.pop(context); // 바텀 시트 닫기

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationCompleteView(
          parkingLot: parkingLot,
          vehiclePlate: vehiclePlate,
          expectedArrival: expectedArrival,
          expectedExit: expectedExit,
          fee: fee,
        ),
      ),
    );
  }

  ThemeData get _pickerTheme => Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: mainColor,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
      );

  Future<void> _selectArrivalDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedArrivalTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(data: _pickerTheme, child: child!),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedArrivalTime),
        builder: (context, child) => Theme(data: _pickerTheme, child: child!),
      );

      if (time != null && mounted) {
        setState(() {
          selectedArrivalTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectExitDateTime() async {
    final initialDate =
        selectedExitTime ?? selectedArrivalTime.add(const Duration(hours: 2));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: selectedArrivalTime,
      lastDate: DateTime.now().add(const Duration(days: 31)),
      builder: (context, child) => Theme(data: _pickerTheme, child: child!),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) => Theme(data: _pickerTheme, child: child!),
      );

      if (time != null && mounted) {
        setState(() {
          selectedExitTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(dt.year, dt.month, dt.day);

    if (target == today) return '오늘';
    if (target == tomorrow) return '내일';
    if (dt.year == now.year) {
      return '${dt.month.toString().padLeft(2, '0')}월 ${dt.day.toString().padLeft(2, '0')}일';
    }
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    return '$yy년 ${dt.month.toString().padLeft(2, '0')}월 ${dt.day.toString().padLeft(2, '0')}일';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

  /// 주차 일수 계산 (날짜 기준)
  int? _calculateParkingDays() {
    if (selectedExitTime == null) {
      return null;
    }

    final arrivalDate = DateTime(
      selectedArrivalTime.year,
      selectedArrivalTime.month,
      selectedArrivalTime.day,
    );
    final exitDate = DateTime(
      selectedExitTime!.year,
      selectedExitTime!.month,
      selectedExitTime!.day,
    );

    final daysDifference = exitDate.difference(arrivalDate).inDays + 1;

    return daysDifference > 0 ? daysDifference : null;
  }

  /// 주차 시간 계산 (분 단위)
  int? _calculateParkingMinutes() {
    if (selectedExitTime == null) {
      return null;
    }

    final parkingDuration = selectedExitTime!.difference(selectedArrivalTime);
    final parkingMinutes = parkingDuration.inMinutes;

    return parkingMinutes > 0 ? parkingMinutes : null;
  }

  /// 예상 결제 금액 계산
  int? _calculateEstimatedFee() {
    if (selectedExitTime == null) {
      return null;
    }

    final valetFee = widget.parkingLot.basePrice;
    final dailyParkingFee = widget.parkingLot.unitPrice;

    if (valetFee == null || dailyParkingFee == null) {
      return null;
    }

    // PriceService로 전체 요금 계산
    return PriceService.calculateTotalFee(
      selectedArrivalTime,
      selectedExitTime!,
      valetFee,
      dailyParkingFee,
    );
  }

  Widget _buildMeetingPointInfo() {
    ParkingLot parkingLot = widget.parkingLot;
    double? meetingLat;
    double? meetingLon;
    String? meetingPoint;
    String? meetingGuide;

    meetingLat = parkingLot.meetingLat;
    meetingLon = parkingLot.meetingLon;
    meetingPoint = parkingLot.meetingPoint;
    meetingGuide = parkingLot.meetingGuide;

    // 미팅 포인트 정보가 없으면 표시하지 않음
    if (meetingPoint == null && meetingLat == null) {
      return SizedBox.shrink();
    }

    final hasLocation = meetingLat != null && meetingLon != null;

    return VStack([
      '차량 인수 위치'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
      12.heightBox,

      VStack([
            // 미팅 포인트 설명
            if (meetingPoint != null) ...[
              (meetingPoint).text.size(16).bold.ellipsis.make(),
              4.heightBox,
            ],

            // 미팅 가이드
            if (meetingGuide != null) ...[
              HStack([
                Icon(Icons.info_outline, size: 16, color: errorColor),
                4.widthBox,
                Expanded(
                  child: (meetingGuide).text.size(14).color(errorColor).make(),
                ),
              ]),
              12.heightBox,
            ],

            // 길찾기 버튼
            if (hasLocation)
              HStack([
                    Icon(
                      Icons.navigation,
                      size: 18,
                      color: Colors.white,
                    ).rotate45().pOnly(bottom: 4),
                    4.widthBox,
                    '길찾기'.text
                        .size(14)
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
          .make(),
    ]);
  }

  Widget _buildVehicleSelector(List<Vehicle>? vehicles) {
    return VStack([
      // Title
      HStack([
        '차량 선택'.text.color(Colors.grey.shade600).size(15).semiBold.make(),
        Spacer(),
        // 등록 버튼
        HStack([
          Icon(Icons.add_circle, size: 18, color: mainColor),
          4.widthBox,
          '차량 등록'.text.size(15).color(mainColor).bold.make(),
        ]).box.make().onTap(() async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VehicleAddScreen()),
          );
          if (result == true && mounted) {
            final updatedVehicles = ref.read(userVehiclesProvider);
            if (updatedVehicles != null && updatedVehicles.isNotEmpty) {
              setState(() {
                selectedVehicleId = updatedVehicles.last.id;
              });
            }
          }
        }),
      ]),
      12.heightBox,

      // Vehicle List
      if (vehicles == null)
        VStack([
              16.heightBox,
              Icon(
                Icons.directions_car_outlined,
                size: 50,
                color: Colors.grey.shade400,
              ),
              16.heightBox,
              '차량 정보 확인 중...'.text.size(14).color(Colors.grey.shade600).make(),
              8.heightBox,
              '등록된 차량이 없다면\n차량을 먼저 등록해주세요'.text
                  .size(12)
                  .color(Colors.grey.shade500)
                  .center
                  .make(),
              16.heightBox,
            ], crossAlignment: CrossAxisAlignment.center)
            .centered()
            .p16()
            .box
            .rounded
            .color(Colors.grey.shade50)
            .border(color: Colors.grey.shade200)
            .make()
      else if (vehicles.isEmpty)
        VStack([
              16.heightBox,
              Icon(
                Icons.car_rental_outlined,
                size: 60,
                color: Colors.orange.shade300,
              ),
              16.heightBox,
              '등록된 차량이 없습니다'.text
                  .size(16)
                  .bold
                  .color(Colors.grey.shade700)
                  .make(),
              8.heightBox,
              '차량을 먼저 등록해주세요'.text.size(14).color(Colors.grey.shade500).make(),
              24.heightBox,
              HStack([
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    8.widthBox,
                    '차량 등록하기'.text.white.bold.size(14).make(),
                  ])
                  .centered()
                  .pSymmetric(v: 12, h: 20)
                  .box
                  .roundedLg
                  .color(Vx.purple600)
                  .make()
                  .onInkTap(() async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VehicleAddScreen(),
                      ),
                    );
                    if (result == true && mounted) {
                      final updatedVehicles = ref.read(userVehiclesProvider);
                      if (updatedVehicles != null &&
                          updatedVehicles.isNotEmpty) {
                        setState(() {
                          selectedVehicleId = updatedVehicles.last.id;
                        });
                      }
                    }
                  }),
              16.heightBox,
            ])
            .centered()
            .p16()
            .box
            .rounded
            .color(Colors.orange.shade50)
            .border(color: Colors.orange.shade200)
            .make()
      else
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: HStack(
            vehicles.map((vehicle) {
              final isSelected = selectedVehicleId == vehicle.id;
              final vehicleInfo = [
                if (vehicle.manufacturer != null) vehicle.manufacturer,
                if (vehicle.model != null) vehicle.model,
              ].where((e) => e != null && e.isNotEmpty).join(' ');

              return VStack([
                    HStack([
                      Image.asset(
                        VehicleImageService.getImagePath(
                          manufacturer: vehicle.manufacturer,
                          model: vehicle.model,
                        ),
                        fit: BoxFit.contain,
                        width: 50,
                        height: 36,
                      ),
                      Spacer(),
                      Icon(Icons.check_circle, size: 24, color: Vx.white),
                    ]),
                    18.heightBox,
                    if (vehicleInfo.isNotEmpty)
                      vehicleInfo.text
                          .size(18)
                          .color(isSelected ? Vx.white : Vx.black)
                          .bold
                          .make(),
                    vehicle.plateNumber.text
                        .size(15)
                        .color(
                          isSelected ? Colors.white70 : Colors.grey.shade500,
                        )
                        .make(),
                  ])
                  .p16()
                  .box
                  .width(MediaQuery.of(context).size.width * 0.55)
                  .rounded
                  .color(isSelected ? mainColor : Colors.white)
                  .border(color: isSelected ? mainColor : Colors.grey.shade300)
                  .make()
                  .onInkTap(() {
                    setState(() {
                      selectedVehicleId = vehicle.id;
                    });
                  })
                  .pOnly(right: 8);
            }).toList(),
          ),
        ),
    ]);
  }

  Widget _buildPrice() {
    final ParkingLot parkingLot = widget.parkingLot;
    // 요금 정보가 없으면 섹션 숨김
    if (parkingLot.basePrice == null || parkingLot.unitPrice == null) {
      return SizedBox.shrink();
    }

    try {
      // 출차 시간 미선택 시 입차 시간 기준으로 0일 계산
      final arrivalTime = selectedArrivalTime;
      final exitTime = selectedExitTime ?? selectedArrivalTime;

      final valetFee = parkingLot.basePrice!;
      final dailyParkingFee = parkingLot.unitPrice!;

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
      final account = parkingLot.accountNumber;

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

            if (selectedExitTime == null) ...[
              4.heightBox,
              '※ 출차 시간을 선택하지 않아 1일 기준으로 계산되었습니다'
                  .text.size(11).color(Colors.orange.shade700).make(),
            ],

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

            if (account != null) ...[
              Divider(),

              '요금 결제를 위한 계좌'.text
                  .color(Colors.grey.shade600)
                  .size(12)
                  .bold
                  .make(),
              4.heightBox,

              HStack([
                    account.text.color(Colors.black54).bold.make().expand(),
                    Icon(Icons.copy, size: 20)
                        .p8()
                        .box
                        .white
                        .rounded
                        .border(color: Colors.grey.shade100)
                        .make()
                        .onInkTap(() {
                          Clipboard.setData(ClipboardData(text: account));
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
            ],
          ])
          .p16()
          .wFull(context)
          .box
          .roundedSM
          .white
          .border(color: Colors.grey.shade300)
          .make();
    } catch (e) {
      // 날짜 파싱 실패 시 섹션 숨김
      return SizedBox.shrink();
    }
  }
}
