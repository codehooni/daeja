import 'package:daeja/core/widgets/button/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/widgets/form/phone_number_form.dart';
import '../../domain/services/phone_validation_service.dart';
import '../providers/auth_provider.dart';
import 'verification_code_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  // 핸드폰 번호 관리
  String phoneNumber = '';
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPhoneValid = false;
  bool _isSending = false;

  final PhoneValidationService _validationService = PhoneValidationService();

  Future<void> _sendVerificationCode() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final phoneNumber = _phoneController.text;
      final internationalNumber =
          _validationService.convertToInternationalFormat(phoneNumber);

      final authController = ref.read(authControllerProvider);
      final verificationId =
          await authController.sendVerificationCode(internationalNumber);

      // 화면 전환
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
          ),
        ),
      );
    } catch (e) {
      // 에러 처리
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호 전송 실패: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // 반응형 계산
    final isTablet = width > 600;

    // 반응형 텍스트 크기
    final titleSize = isTablet ? 32.0 : 24.0;
    final subtitleSize = isTablet ? 18.0 : 16.0;
    final labelSize = isTablet ? 16.0 : 14.0;
    final buttonTextSize = isTablet ? 20.0 : 18.0;

    // 반응형 패딩 및 간격
    final horizontalPadding = isTablet ? 32.0 : width * 0.05;
    final topPadding = isTablet ? 32.0 : height * 0.01;
    final verticalSpacing = isTablet ? 32.0 : height * 0.05;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                '전화번호로 로그인'.text.size(titleSize).bold.make(),

                SizedBox(height: 8),

                // sub title
                '본인 인증을 위해 전화번호를 입력해주세요.'.text
                    .size(subtitleSize)
                    .color(Colors.grey.shade500)
                    .fontWeight(FontWeight.w500)
                    .make(),

                SizedBox(height: verticalSpacing),

                // phone number input form
                phoneNumberInputForm(labelSize),

                SizedBox(height: verticalSpacing),

                // login button
                BigButton(
                  isEnabled: _isPhoneValid && !_isSending,
                  onTap: _isPhoneValid && !_isSending ? _sendVerificationCode : null,
                  child: _isSending
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : '인증번호 받기'.text
                          .size(buttonTextSize)
                          .color(
                            _isPhoneValid ? Colors.white : Colors.grey.shade500,
                          )
                          .bold
                          .make(),
                ),
              ],
            ).pOnly(
              left: horizontalPadding,
              top: topPadding,
              right: horizontalPadding,
              bottom: topPadding,
            ),
      ),
    );
  }

  Widget phoneNumberInputForm(double labelSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        '휴대폰 번호'.text.size(labelSize).bold.make(),

        SizedBox(height: 8),

        // form
        PhoneNumberForm(
          controller: _phoneController,
          focusNode: _focusNode,
          onValidationChanged: (isValid) {
            setState(() {
              _isPhoneValid = isValid;
            });
          },
        ),
      ],
    );
  }
}
