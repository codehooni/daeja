import '../models/validation_result.dart';

class PhoneValidationService {
  ValidationResult validate(String phoneNumber) {
    // 하이픈 제거하고 숫자만 추출
    final digitsOnly = phoneNumber.replaceAll('-', '').trim();

    // 빈 값 체크
    if (digitsOnly.isEmpty) {
      return ValidationResult.error('전화번호를 입력해주세요');
    }

    // 숫자만 포함되어 있는지 체크
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return ValidationResult.error('숫자만 입력해주세요');
    }

    // 11자리 체크
    if (digitsOnly.length != 11) {
      return ValidationResult.error('11자리 전화번호를 입력해주세요');
    }

    // 010으로 시작하는지 체크
    if (!digitsOnly.startsWith('010')) {
      return ValidationResult.error('010으로 시작하는 번호를 입력해주세요');
    }

    return ValidationResult.success();
  }

  /// 하이픈을 제거한 순수 숫자만 반환
  String getDigitsOnly(String phoneNumber) {
    return phoneNumber.replaceAll('-', '').trim();
  }

  /// 한국 전화번호를 국제 형식으로 변환
  /// "010-1234-5678" → "+821012345678"
  String convertToInternationalFormat(String phoneNumber) {
    // "010-1234-1234" → "01012341234"
    final digitsOnly = phoneNumber.replaceAll('-', '').trim();

    // "01012341234" → "+821012341234"
    if (digitsOnly.startsWith('0')) {
      return '+82${digitsOnly.substring(1)}';
    }
    return '+82$digitsOnly';
  }
}
