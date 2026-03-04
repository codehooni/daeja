class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}
