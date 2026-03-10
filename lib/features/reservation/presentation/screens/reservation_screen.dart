import 'package:daeja/features/reservation/presentation/screens/reservation_complete_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/services/price_service.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../parking/domain/models/parking_lot.dart';
import '../../../user/presentation/providers/user_provider.dart';
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

    // 로그인 체크
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: '발렛 예약'.text.size(18).bold.make(),
          backgroundColor: Colors.white,
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
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            VStack([
              // 주차장 정보
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: HStack([
                  VxBox().width(6).height(100).purple700.make(),
                  12.widthBox,
                  VStack([
                    HStack([
                      widget.parkingLot.name.text.size(20).bold.make(),
                      Spacer(),

                      // 주차장 타입
                      _buildTypeChip(widget.parkingLot.type).pOnly(right: 16),
                    ]),
                    8.heightBox,
                    HStack([
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      4.widthBox,
                      widget.parkingLot.address.text
                          .size(14)
                          .gray600
                          .make()
                          .expand(),
                    ]),
                  ]).expand(),
                ]).box.white.make(),
              ),

              24.heightBox,

              // 차량 선택
              VStack([
                // Title
                HStack([
                  Icon(
                    Icons.directions_car_filled,
                    size: 22,
                    color: Vx.purple500,
                  ),
                  8.widthBox,
                  '차량 선택'.text.size(16).bold.make(),
                  Spacer(),
                  '+ 등록'.text
                      .size(12)
                      .color(Vx.purple700)
                      .make()
                      .pSymmetric(h: 8, v: 4)
                      .box
                      .roundedSM
                      .purple100
                      .make()
                      .onInkTap(() async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VehicleAddScreen(),
                          ),
                        );
                        // 차량 추가 후 돌아오면 첫 번째 차량 자동 선택
                        if (result == true && mounted) {
                          final updatedVehicles = ref.read(
                            userVehiclesProvider,
                          );
                          if (updatedVehicles != null &&
                              updatedVehicles.isNotEmpty) {
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
                        '차량 정보 확인 중...'.text
                            .size(14)
                            .color(Colors.grey.shade600)
                            .make(),
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
                        '차량을 먼저 등록해주세요'.text
                            .size(14)
                            .color(Colors.grey.shade500)
                            .make(),
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
                                  builder: (context) =>
                                      const VehicleAddScreen(),
                                ),
                              );
                              // 차량 추가 후 돌아오면 첫 번째 차량 자동 선택
                              if (result == true && mounted) {
                                final updatedVehicles = ref.read(
                                  userVehiclesProvider,
                                );
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
                  ...vehicles.map((vehicle) {
                    final isSelected = selectedVehicleId == vehicle.id;
                    final vehicleInfo = [
                      if (vehicle.manufacturer != null) vehicle.manufacturer,
                      if (vehicle.model != null) vehicle.model,
                      if (vehicle.color != null) vehicle.color,
                    ].where((e) => e != null && e.isNotEmpty).join(' | ');

                    return VStack([
                      HStack([
                            Icon(
                              Icons.directions_car_filled,
                              size: 26,
                              color: Vx.purple500,
                            ).p(8).box.roundedFull.purple100.make(),
                            16.widthBox,
                            VStack([
                              vehicle.plateNumber.text.size(16).bold.make(),
                              if (vehicleInfo.isNotEmpty)
                                vehicleInfo.text
                                    .size(12)
                                    .color(Colors.grey.shade600)
                                    .make(),
                            ]),
                            Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle, color: Vx.purple500),
                          ])
                          .p(16)
                          .box
                          .rounded
                          .white
                          .border(
                            color: isSelected
                                ? Vx.purple500
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          )
                          .make()
                          .onInkTap(() {
                            setState(() {
                              selectedVehicleId = vehicle.id;
                            });
                          }),
                      8.heightBox,
                    ]);
                  }).toList(),
              ]),
              16.heightBox,

              // 예약 안내 정보 (주차장에서 제공)
              if (widget.parkingLot.reservationInfo != null &&
                  widget.parkingLot.reservationInfo!.isNotEmpty) ...[
                VStack([
                      HStack([
                        Icon(Icons.info_outline, size: 22, color: Vx.purple500),
                        8.widthBox,
                        '예약 안내'.text.size(16).bold.make(),
                      ]),
                      12.heightBox,
                      widget.parkingLot.reservationInfo!.text
                          .size(14)
                          .color(Colors.grey.shade700)
                          .make(),
                    ])
                    .p16()
                    .box
                    .rounded
                    .color(const Color(0xFFF3E5FF))
                    .border(color: const Color(0xFFE1BEF5))
                    .make(),
                16.heightBox,
              ],

              // 예약 날짜
              VStack([
                    // Title
                    HStack([
                      Icon(
                        Icons.access_time_sharp,
                        size: 22,
                        color: Vx.purple500,
                      ),
                      8.widthBox,
                      '일정 입력'.text.size(16).bold.make(),
                    ]),
                    12.heightBox,

                    // Schedule Container (도착 예정)
                    HStack([
                      '도착 예정 시간'.text.size(14).bold.make(),
                      4.widthBox,
                      '*'.text.size(18).color(Colors.red).make(),
                    ]),
                    8.heightBox,
                    HStack([
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey.shade500,
                            size: 16,
                          ),
                          12.widthBox,
                          _formatDateTime(
                            selectedArrivalTime,
                          ).text.size(14).make(),
                          Spacer(),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                            size: 16,
                          ),
                        ])
                        .px12()
                        .py12()
                        .box
                        .roundedSM
                        .color(Colors.grey.shade50)
                        .border(color: Colors.grey.shade300)
                        .make()
                        .onInkTap(() => _selectArrivalDateTime()),
                    12.heightBox,

                    // Schedule Container (출차 예정)
                    HStack([
                      '출차 예정 시간'.text.size(14).bold.make(),
                      Spacer(),
                      '선택사항'.text
                          .size(10)
                          .color(Colors.grey.shade700)
                          .make()
                          .p4()
                          .box
                          .roundedSM
                          .color(Colors.grey.shade100)
                          .make(),
                    ]),
                    8.heightBox,
                    HStack([
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey.shade500,
                            size: 16,
                          ),
                          12.widthBox,
                          (selectedExitTime != null
                                  ? _formatDateTime(selectedExitTime!)
                                  : '선택 안 함')
                              .text
                              .size(14)
                              .color(
                                selectedExitTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              )
                              .make(),
                          Spacer(),
                          if (selectedExitTime != null)
                            IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  selectedExitTime = null;
                                });
                              },
                            )
                          else
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                              size: 16,
                            ),
                        ])
                        .px12()
                        .py12()
                        .box
                        .roundedSM
                        .color(Colors.grey.shade50)
                        .border(color: Colors.grey.shade300)
                        .make()
                        .onInkTap(() => _selectExitDateTime()),
                  ])
                  .p16()
                  .box
                  .rounded
                  .white
                  .border(color: Colors.grey.shade300)
                  .make(),

              24.heightBox,

              // 주의사항
              VStack([
                // Title
                HStack([
                  Icon(
                    Icons.description_outlined,
                    size: 22,
                    color: Vx.purple500,
                  ),
                  8.widthBox,
                  '요청 사항'.text.size(16).bold.make(),
                  Spacer(),
                ]),
                12.heightBox,
                Stack(
                  children: [
                    TextField(
                      controller: _requestController,
                      maxLines: 2,
                      maxLength: 200,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '주차장 사장님께 전달할 메세지가 있다면 남겨주세요',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        counterText: '', // 기본 카운터 숨김
                        contentPadding: const EdgeInsets.fromLTRB(
                          12,
                          12,
                          12,
                          12,
                        ),

                        // 기본 상태 border
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // 포커스된 상태 border
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Vx.purple500, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // 에러 상태 border
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // 포커스된 에러 상태 border
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // 글자 수 카운터를 TextField 안에 표시
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Text(
                        '${_requestController.text.length}/200',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),

              200.heightBox,
            ]).p20().scrollVertical(),

            // Bottom
            // 예약하기 버튼
            Align(
              alignment: AlignmentGeometry.bottomCenter,
              child:
                  VStack([
                        // 예상 결제금액 - 출차 예정 시간이 설정된 경우에만 표시
                        if (selectedExitTime != null &&
                            _calculateEstimatedFee() != null) ...[
                          VStack([
                            HStack([
                              (widget.parkingLot.type == ParkingLotType.valet
                                      ? '예상 발렛 + 주차 결제금액'
                                      : '예상 결제금액')
                                  .text
                                  .size(14)
                                  .color(Colors.grey.shade700)
                                  .make(),
                              Spacer(),
                              '${_calculateEstimatedFee()!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                                  .text
                                  .size(20)
                                  .purple500
                                  .bold
                                  .make(),
                            ]),
                            4.heightBox,
                            HStack([
                              (widget.parkingLot.type == ParkingLotType.valet
                                      ? '주차 일수: ${_calculateParkingDays()}일'
                                      : '주차 시간: ${_formatDuration(_calculateParkingMinutes()!)}')
                                  .text
                                  .size(12)
                                  .color(Colors.grey.shade600)
                                  .make(),
                              Spacer(),
                            ]),
                            if (widget.parkingLot.type ==
                                ParkingLotType.valet) ...[
                              4.heightBox,
                              '※ 세차나 기타 상품 이용시 추가요금이 발생합니다'.text
                                  .size(11)
                                  .color(Colors.orange.shade700)
                                  .make(),
                            ],
                          ]),
                          8.heightBox,
                        ],

                        (isSubmitting
                                ? CircularProgressIndicator(
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
                                  ? () => _submitReservation(currentUser.uid)
                                  : null,
                            )
                            .box
                            .make()
                            .wFull(context),
                      ])
                      .pOnly(
                        left: 16,
                        top: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                      )
                      .box
                      .white
                      .withShadow([
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                          spreadRadius: 0,
                        ),
                      ])
                      .make(),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _selectArrivalDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedArrivalTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedArrivalTime),
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
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}. ${dateTime.month.toString().padLeft(2, '0')}. ${dateTime.day.toString().padLeft(2, '0')}. '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        .color(color)
        .make()
        .pSymmetric(h: 8, v: 4)
        .box
        .color(color.withAlpha(20))
        .roundedSM
        .make();
  }
}
