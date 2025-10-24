import 'package:daeja/constants/constants.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/cubit/parking_lot_state.dart';
import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/presentation/widget/sheet/badge/time_badge.dart';
import 'package:daeja/presentation/widget/sheet/navigation_selection_sheet.dart';
import 'package:daeja/presentation/widget/sheet/sheet_handle_bar.dart';
import 'package:daeja/utils/share_parking_lot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/time_format.dart';

class ParkingDetailSheet extends StatelessWidget {
  final ParkingLot parking;

  const ParkingDetailSheet({super.key, required this.parking});

  static void show(BuildContext context, ParkingLot parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 투명하게 설정
      builder: (context) => ParkingDetailSheet(parking: parking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicBottomSheet(parking: parking);
  }
}

class DynamicBottomSheet extends StatefulWidget {
  final ParkingLot parking;

  const DynamicBottomSheet({super.key, required this.parking});

  @override
  State<DynamicBottomSheet> createState() => _DynamicBottomSheetState();
}

class _DynamicBottomSheetState extends State<DynamicBottomSheet> {
  final GlobalKey _contentKey = GlobalKey();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  double _minChildSize = 0.3;
  double _maxChildSize = 0.8;
  bool _isExpanded = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    _sheetController.addListener(() {
      // controller가 sheet에 연결되어 있는지  확인
      if (!_sheetController.isAttached) return;

      // size :  0.0 ~ 1.0 화면 비율
      final size = _sheetController.size;

      // 확장시
      if (!_isExpanded && size > _minChildSize + 0.1 && mounted) {
        setState(() {
          _isExpanded = true;
        });

        // 확장 상태가 변경되면 크기 재측정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSizes(recalculate: true);
        });
      }
    });

    // 초기 렌더링 후 크기 측정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isExpanded) {
        _updateSizes();
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _updateSizes({bool recalculate = false}) {
    final RenderBox? renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null && mounted) {
      final contentHeight = renderBox.size.height; // 컨텐츠 실제 높이
      final screenHeight = MediaQuery.of(context).size.height; // 화면 높이

      // 헤더 + 핸들바 + 버튼 + 패딩 높이
      const double fixedHeight = 24 + 50 + 100 + 32;
      // 모든 sheet의 높이
      final totalHeight = contentHeight + fixedHeight;

      // 처음 한번만 측정
      if (!_hasInitialized) {
        final calculatedMin = (totalHeight / screenHeight).clamp(0.3, 0.8);

        setState(() {
          _minChildSize = calculatedMin;
          _hasInitialized = true;
        });
      }
      // 확장 시 재계산
      else if (_isExpanded && recalculate) {
        setState(() {
          _minChildSize = 0.0;
        });
        final calculatedMax = ((totalHeight + 50) / screenHeight).clamp(
          0.1,
          0.8,
        );

        if (calculatedMax != _maxChildSize) {
          setState(() {
            _maxChildSize = calculatedMax;
          });
        }
        // 확장 애니메이션이 끝난 후 _minChildSize 복구
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            final calculatedMin = (fixedHeight / screenHeight).clamp(0.3, 0.8);
            setState(() {
              _minChildSize = calculatedMin;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _minChildSize,
      minChildSize: _minChildSize,
      maxChildSize: _maxChildSize,
      expand: false,
      snap: true,
      snapSizes: [_maxChildSize],
      snapAnimationDuration: Duration(milliseconds: 200),

      builder: (context, scrollController) {
        if (!_isExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateSizes();
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SheetHandleBar(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildHeader(context),
              ),

              SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    key: _contentKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildContent(context)],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.0),
                child: _buildButton(context),
              ),

              SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 0),
      child: _isExpanded ? _buildExpandedContent() : _buildBasicContent(),
    );
  }

  // 기본 컨텐츠 (축소 상태)
  Widget _buildBasicContent() {
    return Column(
      key: ValueKey('basic'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: _isExpanded ? 16.0 : 8.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // 기본 정보 (항상 표시)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 전체 주차면
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '전체 주차면',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${widget.parking.wholNpls}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),

                  // 잔여 주차면
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '잔여 주차면',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${widget.parking.totalRemaining}',
                        style: TextStyle(
                          color: widget.parking.gnrl == 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (!_isExpanded) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.expand_more, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '위로 당겨 상세정보 보기',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],

              // 확장 시 상세 정보
              if (_isExpanded) ...[
                SizedBox(height: 16),
                Divider(height: 1),
                SizedBox(height: 16),

                // 주차 구역별 현황 제목
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '주차 구역별 현황',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // 주차 구역 칩들
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    if (widget.parking.gnrl != null)
                      _buildParkingTypeChip(
                        '일반',
                        widget.parking.gnrl!,
                        Icons.local_parking,
                      ),
                    if (widget.parking.lgvh != null)
                      _buildParkingTypeChip(
                        '경차',
                        widget.parking.lgvh!,
                        Icons.directions_car,
                      ),
                    if (widget.parking.hvvh != null)
                      _buildParkingTypeChip(
                        '대형',
                        widget.parking.hvvh!,
                        Icons.local_shipping,
                      ),
                    if (widget.parking.emvh != null)
                      _buildParkingTypeChip(
                        '긴급',
                        widget.parking.emvh!,
                        Icons.emergency,
                      ),
                    if (widget.parking.hndc != null)
                      _buildParkingTypeChip(
                        '장애인',
                        widget.parking.hndc!,
                        Icons.accessible,
                      ),
                    if (widget.parking.wmon != null)
                      _buildParkingTypeChip(
                        '여성전용',
                        widget.parking.wmon!,
                        Icons.woman,
                      ),
                    if (widget.parking.etc != null)
                      _buildParkingTypeChip(
                        '기타',
                        widget.parking.etc!,
                        Icons.more_horiz,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 주차 구역 타입 칩
  Widget _buildParkingTypeChip(String label, int count, IconData icon) {
    final isAvailable = count > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isAvailable
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: isAvailable
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 6.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isAvailable
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 4.0),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: isAvailable
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // 확장 컨텐츠 (최대 사이즈일 때)
  Widget _buildExpandedContent() {
    return Column(
      key: ValueKey('expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기본 정보
        _buildBasicContent(),

        SizedBox(height: 16),

        // 추가 정보들
        Text(
          '상세 정보',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),

        SizedBox(height: 12),

        // 운영 요일
        if (widget.parking.parkDay != null)
          _buildInfoRow(
            context,
            icon: Icons.calendar_today,
            label: '운영 요일',
            value: widget.parking.parkDay!,
          ),

        if (widget.parking.parkDay != null) SizedBox(height: 8),

        // 평일 운영 시간
        if (widget.parking.wkdyStrt != null && widget.parking.wkdyEnd != null)
          _buildInfoRow(
            context,
            icon: Icons.access_time,
            label: '평일 운영',
            value: TimeFormat.operatingHours(
              widget.parking.wkdyStrt,
              widget.parking.wkdyEnd,
            ),
          ),
        if (widget.parking.parkDay != null) SizedBox(height: 8),

        // 주말 운영 시간
        if (widget.parking.lhdyStrt != null && widget.parking.lhdyEnd != null)
          _buildInfoRow(
            context,
            icon: Icons.access_time_filled,
            label: '주말 운영',
            value: TimeFormat.operatingHours(
              widget.parking.lhdyStrt,
              widget.parking.lhdyEnd,
            ),
          ),

        if (widget.parking.lhdyStrt != null && widget.parking.lhdyEnd != null)
          SizedBox(height: 8),

        // 기본 주차 정보
        if (widget.parking.basicTime != null &&
            widget.parking.basicFare != null)
          _buildInfoRow(
            context,
            icon: Icons.local_parking,
            label: '기본 요금',
            value:
                '${widget.parking.basicTime}분 / ${widget.parking.basicFare}원',
          ),

        if (widget.parking.basicTime != null &&
            widget.parking.basicFare != null)
          SizedBox(height: 8),

        // 추가 주차 정보
        if (widget.parking.addTime != null && widget.parking.addFare != null)
          _buildInfoRow(
            context,
            icon: Icons.add_circle_outline,
            label: '추가 요금',
            value: '${widget.parking.addTime}분당 ${widget.parking.addFare}원',
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // 색상 변경
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14.0,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final state = context.read<ParkingLotCubit>().state;
    final lastUpdated = state is ParkingLotResult ? state.lastUpdated : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 주차장 이름
        Expanded(
          child: Text(
            widget.parking.name.toString(),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        SizedBox(width: 10.0),

        if (lastUpdated != null) TimeBadge(lastUpdated: lastUpdated),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Column(
      children: [
        // 주소
        Row(
          children: [
            // 주소 Icon
            Icon(
              Icons.location_on,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),

            SizedBox(width: 5.0),

            // 주소 Text
            Expanded(
              child: Text(
                widget.parking.addr.toString(),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0),

        // 버튼들
        Row(
          children: [
            // 길찾기 버튼
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationSelectionSheet.show(context, widget.parking);
                },
                icon: Icon(Icons.directions, size: 18.0),
                label: Text(
                  '길찾기',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            SizedBox(width: 10.0),

            // 공유 버튼
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  ShareParkingLot.shareParkingInfo(widget.parking);
                },
                icon: Icon(Icons.share, size: 18.0),
                label: Text(
                  '공유',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
