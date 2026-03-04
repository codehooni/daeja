extension PhoneFormatter on String {
  String get toKoreanPhone {
    String digits = replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('82')) digits = '0${digits.substring(2)}';
    if (digits.length < 11) return this;

    return "${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}";
  }
}
