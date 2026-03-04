import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../features/auth/domain/services/phone_validation_service.dart';

class PhoneNumberForm extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(bool isValid)? onValidationChanged;

  const PhoneNumberForm({
    super.key,
    this.controller,
    this.focusNode,
    this.onValidationChanged,
  });

  @override
  State<PhoneNumberForm> createState() => _PhoneNumberFormState();
}

class _PhoneNumberFormState extends State<PhoneNumberForm> {
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  void _validatePhoneNumber() {
    final service = PhoneValidationService();
    final phoneNumber = widget.controller?.text ?? '';
    final result = service.validate(phoneNumber);

    setState(() {
      _hasError = !result.isValid;
      _errorMessage = result.errorMessage;
    });

    // 부모 위젯에 validation 상태 전달
    widget.onValidationChanged?.call(result.isValid);
  }

  @override
  Widget build(BuildContext context) {
    // 반응형 계산
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    // 반응형 크기
    final isoTextSize = isTablet ? 18.0 : 16.0;
    final isoPadding = isTablet ? 20.0 : 16.0;
    final isoSpacing = isTablet ? 16.0 : 12.0;
    final inputTextSize = isTablet ? 20.0 : 18.0;
    final inputPadding = isTablet ? 20.0 : 16.0;
    final borderRadius = isTablet ? 18.0 : 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ISO
        '🇰🇷+82'.text
            .size(isoTextSize)
            .color(Colors.grey.shade700)
            .fontWeight(FontWeight.w500)
            .make()
            .pSymmetric(h: isoPadding, v: isoPadding)
            .box
            .rounded
            .border(color: Colors.grey.shade300)
            .color(Colors.grey.shade50)
            .make(),

        SizedBox(width: isoSpacing),

        // Number + Error Message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                cursorColor: Colors.black,
                cursorWidth: 1,
                keyboardType: TextInputType.phone,
                selectionControls: EmptyTextSelectionControls(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneNumberFormatter(),
                ],
                style: TextStyle(
                  fontSize: inputTextSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: '010-1234-1234',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: inputTextSize,
                    color: Colors.grey.shade400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: inputPadding,
                    vertical: inputPadding,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  errorText: _hasError ? _errorMessage : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Limit to 11 digits maximum (Korean phone numbers)
    if (text.length > 11) {
      return oldValue;
    }

    // Detect if this is a deletion operation
    final isDeletion = newValue.text.length < oldValue.text.length;

    // Format the text
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 2 || i == 6) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();

    // Special handling for deletion: if formatted ends with '-', remove it
    // This prevents the cursor from being stuck after the separator
    if (isDeletion && formatted.endsWith('-')) {
      final withoutSeparator = formatted.substring(0, formatted.length - 1);
      return TextEditingValue(
        text: withoutSeparator,
        selection: TextSelection.collapsed(offset: withoutSeparator.length),
      );
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EmptyTextSelectionControls extends MaterialTextSelectionControls {
  @override
  Size getHandleSize(double textLineHeight) => Size.zero;

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textHeight, [
    VoidCallback? onTap,
  ]) {
    return SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return Offset.zero;
  }
}
