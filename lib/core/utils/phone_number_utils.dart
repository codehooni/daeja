class PhoneNumberUtils {
  /// 국제 전화번호 형식(+821012341243)을 한국 형식(010-1234-1243)으로 변환
  static String globalToKorea(String global) {
    if (global.isEmpty) {
      return '';
    }

    // +82로 시작하지 않으면 그대로 반환
    if (!global.startsWith('+82')) {
      return global;
    }

    // +82 제거 후 한국 번호 추출 (예: 1012341243)
    String koreanNumber = global.substring(3);

    // 10자리가 아니면 그대로 반환
    if (koreanNumber.length != 10) {
      return global;
    }

    // 010-1234-1243 형식으로 변환
    String first = '0${koreanNumber.substring(0, 2)}'; // "010"
    String middle = koreanNumber.substring(2, 6); // "1234"
    String last = koreanNumber.substring(6, 10); // "1243"

    return '$first-$middle-$last';
  }
}
