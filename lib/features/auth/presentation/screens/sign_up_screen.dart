import 'package:daeja/core/services/fcm_token_service.dart';
import 'package:daeja/core/utils/logger.dart';
import 'package:daeja/core/widgets/button/big_button.dart';
import 'package:daeja/core/widgets/checkbox/terms_of_service_agreement.dart';
import 'package:daeja/core/widgets/form/name_form.dart';
import 'package:daeja/features/auth/domain/models/auth_user.dart';
import 'package:daeja/features/user/presentation/providers/user_provider.dart';
import 'package:daeja/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final AuthUser authUser;

  const SignUpScreen({super.key, required this.authUser});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Validation state
  bool _isNameValid = false;
  bool _isTermsAgreed = false;
  bool _isSending = false;

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
                '회원가입'.text.size(titleSize).bold.make(),

                SizedBox(height: 8),

                // sub title
                '서비스 이용을 위해 정보를 입력해주세요.'.text
                    .size(subtitleSize)
                    .color(Colors.grey.shade500)
                    .fontWeight(FontWeight.w500)
                    .make(),

                SizedBox(height: verticalSpacing),

                // name number input form
                nameInputForm(labelSize),

                SizedBox(height: verticalSpacing),

                TermsOfServiceAgreement(
                  onTermsChanged: (isValid) {
                    setState(() {
                      _isTermsAgreed = isValid;
                    });
                  },
                ),

                SizedBox(height: verticalSpacing),

                // login button
                BigButton(
                  isEnabled: _isNameValid && _isTermsAgreed && !_isSending,
                  onTap: (_isNameValid && _isTermsAgreed && !_isSending)
                      ? _handleSignUp
                      : null,
                  child: '가입 완료'.text
                      .size(buttonTextSize)
                      .color(
                        (_isNameValid && _isTermsAgreed)
                            ? Colors.white
                            : Colors.grey.shade500,
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

  Widget nameInputForm(double labelSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        '이름'.text.size(labelSize).bold.make(),

        SizedBox(height: 8),

        // form
        NameForm(
          controller: _nameController,
          focusNode: _focusNode,
          onValidationChanged: (isValid) {
            setState(() {
              _isNameValid = isValid;
            });
          },
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final name = _nameController.text.trim();

      // Create user if needed
      await ref.read(userProvider.notifier).ensureUserExists(widget.authUser);

      final currentUser = ref.read(userProvider).value;
      if (currentUser == null) {
        throw Exception('유저 생성에 실패했습니다');
      }

      // Update user name
      await ref.read(userProvider.notifier).updateUser(name: name);

      Log.s('회원가입 완료: $name');

      // FCM 토큰 저장
      try {
        final fcmTokenService = FCMTokenService();
        await fcmTokenService.initializeAndSaveToken(widget.authUser.uid);
        Log.s('[SignUpScreen] FCM 토큰 저장 완료');
      } catch (e) {
        Log.e('[SignUpScreen] FCM 토큰 저장 실패', e);
        // 토큰 저장 실패해도 회원가입은 진행
      }

      if (!mounted) return;

      // 모든 이전 화면을 제거하고 MainScreen으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false, // 모든 이전 라우트 제거
      );
    } catch (e) {
      Log.e('회원가입 실패', e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
