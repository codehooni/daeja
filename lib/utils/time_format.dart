import 'package:intl/intl.dart';

class TimeFormat {
  static String lastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('MM월 dd일 HH:mm').format(lastUpdated);
    }
  }

  /// 운영 시간 포맷 (예: "09:00 ~ 18:00")
  static String operatingHours(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) {
      return '정보 없음';
    }

    // 6자리 숫자 형식 (예: "090000", "180000")을 "09:00", "18:00"으로 변환
    String formatTime(String time) {
      if (time.length == 6) {
        return '${time.substring(0, 2)}:${time.substring(2, 4)}';
      } else if (time.length == 4) {
        return '${time.substring(0, 2)}:${time.substring(2, 4)}';
      } else if (time.length == 3) {
        return '0${time.substring(0, 1)}:${time.substring(1, 3)}';
      }
      return time;
    }

    final formattedStart = formatTime(startTime);
    final formattedEnd = formatTime(endTime);

    return '$formattedStart ~ $formattedEnd';
  }
}
