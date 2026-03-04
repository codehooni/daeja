import '../models/validation_result.dart';

class NameValidationService {
  ValidationResult validate(String name) {
    final trimmed = name.trim();

    // Empty check
    if (trimmed.isEmpty) {
      return ValidationResult.error('이름을 입력해주세요');
    }

    // Length: 2-20 characters
    if (trimmed.length < 2) {
      return ValidationResult.error('이름은 2자 이상 입력해주세요');
    }

    if (trimmed.length > 20) {
      return ValidationResult.error('이름은 20자 이하로 입력해주세요');
    }

    // Korean, English, spaces only
    final validPattern = RegExp(r'^[가-힣a-zA-Z\s]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return ValidationResult.error('한글, 영문, 공백만 입력 가능합니다');
    }

    // No multiple consecutive spaces
    if (trimmed.contains(RegExp(r'\s{2,}'))) {
      return ValidationResult.error('공백은 한 칸만 허용됩니다');
    }

    return ValidationResult.success();
  }
}
