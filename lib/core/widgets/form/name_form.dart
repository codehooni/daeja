import 'package:flutter/material.dart';

import '../../../features/auth/domain/services/name_validation_service.dart';

class NameForm extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(bool isValid)? onValidationChanged;

  const NameForm({
    super.key,
    this.controller,
    this.focusNode,
    this.onValidationChanged,
  });

  @override
  State<NameForm> createState() => _NameFormState();
}

class _NameFormState extends State<NameForm> {
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_validateName);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_validateName);
    super.dispose();
  }

  void _validateName() {
    final service = NameValidationService();
    final name = widget.controller?.text ?? '';
    final result = service.validate(name);

    setState(() {
      _hasError = !result.isValid;
      _errorMessage = result.errorMessage;
    });

    // Notify parent widget
    widget.onValidationChanged?.call(result.isValid);
  }

  @override
  Widget build(BuildContext context) {
    // 반응형 계산
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    // 반응형 크기
    final inputTextSize = isTablet ? 18.0 : 16.0;
    final inputPadding = isTablet ? 20.0 : 16.0;
    final borderRadius = isTablet ? 18.0 : 16.0;

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      cursorColor: Colors.black,
      cursorWidth: 1,
      keyboardType: TextInputType.name,
      selectionControls: EmptyTextSelectionControls(),
      style: TextStyle(
        fontSize: inputTextSize,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: '홍길동',
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
