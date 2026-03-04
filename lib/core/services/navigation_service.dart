import 'package:daeja/core/utils/logger.dart';
import 'package:daeja/features/reservation/presentation/screens/reservation_detail_screen.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 예약 상세 화면으로 네비게이션
  static Future<void> navigateToReservationDetail(String reservationId) async {
    final context = navigatorKey.currentContext;

    if (context == null) {
      Log.e('[NavigationService] Navigation context is null');
      return;
    }

    Log.d('[NavigationService] 예약 상세 화면으로 이동: $reservationId');

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReservationDetailScreen(
            reservationId: reservationId,
          ),
        ),
      );
    } catch (e) {
      Log.e('[NavigationService] 네비게이션 실패', e);
    }
  }
}
