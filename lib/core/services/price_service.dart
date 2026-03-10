import 'package:intl/intl.dart';

class PriceService {
  // 1. 천 단위 콤마 (기본)
  static String format(num number) {
    return NumberFormat('###,###,###,###').format(number);
  }

  // 2. 소수점 2자리 표기 (고정)
  static String formatDecimal(num number) {
    return NumberFormat('###.0#', 'en_US').format(number);
  }

  // 3. 통화 표기 (원화 기준)
  static String formatCurrency(num number, {String symbol = '₩'}) {
    return NumberFormat.currency(
      locale: 'ko_KR',
      symbol: symbol,
    ).format(number);
  }

  // 4. 주차 예약 앱 특화: '1,000원' 형태로 출력
  static String formatWithUnit(num number) {
    return "${format(number)}원";
  }

  // === 요금 계산 메서드 ===

  /// 날짜 차이 계산 (일수)
  /// [arrivalTime] 입차 시간
  /// [exitTime] 출차 시간
  /// 반환: 사용 일수 (당일 = 1일)
  static int calculateDays(DateTime arrivalTime, DateTime exitTime) {
    // 날짜만 추출 (시간 제거)
    final arrivalDate = DateTime(
      arrivalTime.year,
      arrivalTime.month,
      arrivalTime.day,
    );
    final exitDate = DateTime(
      exitTime.year,
      exitTime.month,
      exitTime.day,
    );

    // 날짜 차이 + 1 = 실제 사용 일수
    // 예: 3월 11일 → 3월 11일 = 1일 (당일)
    // 예: 3월 11일 → 3월 13일 = 3일
    return exitDate.difference(arrivalDate).inDays + 1;
  }

  /// 주차 요금 계산 (발렛 요금 제외)
  /// [arrivalTime] 입차 시간
  /// [exitTime] 출차 시간
  /// [dailyParkingFee] 일일 주차 요금
  /// 반환: 주차 요금 (원)
  static int calculateParkingFee(
    DateTime arrivalTime,
    DateTime exitTime,
    int dailyParkingFee,
  ) {
    final days = calculateDays(arrivalTime, exitTime);
    return days * dailyParkingFee;
  }

  /// 전체 요금 계산 (발렛 요금 + 주차 요금)
  /// [arrivalTime] 입차 시간
  /// [exitTime] 출차 시간
  /// [valetFee] 발렛 기본 요금
  /// [dailyParkingFee] 일일 주차 요금
  /// 반환: 전체 요금 (원)
  static int calculateTotalFee(
    DateTime arrivalTime,
    DateTime exitTime,
    int valetFee,
    int dailyParkingFee,
  ) {
    final parkingFee = calculateParkingFee(
      arrivalTime,
      exitTime,
      dailyParkingFee,
    );
    return valetFee + parkingFee;
  }
}
