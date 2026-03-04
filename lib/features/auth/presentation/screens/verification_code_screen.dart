import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../core/services/fcm_token_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/button/big_button.dart';
import '../../../../features/auth/domain/services/phone_validation_service.dart';
import '../../../../features/user/presentation/providers/user_provider.dart';
import '../../../../presentation/main_screen.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerificationCodeScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends ConsumerState<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PhoneValidationService _validationService = PhoneValidationService();

  bool _isVerifying = false;
  bool _isResending = false;
  int _remainingSeconds = 120; // 2분 (120초)
  Timer? _timer;
  String _currentVerificationId = '';

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();

    // 화면 진입 시 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 120);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('6자리 인증번호를 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      final authController = ref.read(authControllerProvider);
      final user = await authController.verifyCodeAndSignIn(
        verificationId: _currentVerificationId,
        smsCode: _codeController.text,
      );

      if (user != null && mounted) {
        // Ensure user exists in Firestore
        await ref.read(userProvider.notifier).ensureUserExists(user);

        if (!mounted) return;

        // FCM 토큰 저장
        try {
          final fcmTokenService = FCMTokenService();
          await fcmTokenService.initializeAndSaveToken(user.uid);
          Log.s('[VerificationCodeScreen] FCM 토큰 저장 완료');
        } catch (e) {
          Log.e('[VerificationCodeScreen] FCM 토큰 저장 실패', e);
          // 토큰 저장 실패해도 로그인은 진행
        }

        if (!mounted) return;

        final userAsync = ref.read(userProvider);

        if (userAsync.hasError) {
          Log.e('유저 확인 실패', userAsync.error);
        }

        final userData = userAsync.value;

        // Navigate based on user completion status
        if (userData?.name != null && userData!.name!.isNotEmpty) {
          Log.s('로그인 성공');
          // 모든 이전 화면을 제거하고 MainScreen으로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false, // 모든 이전 라우트 제거
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SignUpScreen(authUser: user)),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      // 사용자 친화적 에러 메시지
      String errorMessage = '인증에 실패했습니다';
      if (e.toString().contains('invalid-verification-code')) {
        errorMessage = '인증번호가 올바르지 않습니다';
      } else if (e.toString().contains('session-expired')) {
        errorMessage = '인증 시간이 만료되었습니다';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      final phoneNumber = widget.phoneNumber;
      final internationalNumber = _validationService
          .convertToInternationalFormat(phoneNumber);

      final authController = ref.read(authControllerProvider);
      final verificationId = await authController.sendVerificationCode(
        internationalNumber,
      );

      if (!mounted) return;

      // 타이머 먼저 초기화
      _startTimer();

      setState(() {
        _currentVerificationId = verificationId;
        _codeController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증번호가 재전송되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증번호 재전송에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
    final inputTextSize = isTablet ? 32.0 : 28.0;
    final buttonTextSize = isTablet ? 20.0 : 18.0;
    final timerTextSize = isTablet ? 18.0 : 14.0;

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
                '인증번호 입력'.text.size(titleSize).bold.make(),

                SizedBox(height: 8),

                // sub title
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.phoneNumber,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '로 발송된\n인증번호 6자리를 입력하세요.',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing),

                // OTP 입력 필드
                TextField(
                  controller: _codeController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: TextStyle(
                    fontSize: inputTextSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: inputTextSize,
                      color: Colors.grey.shade300,
                      letterSpacing: 8,
                    ),
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) {
                    // 6자리 입력 시 자동 검증 (선택사항)
                    if (value.length == 6) {
                      _verifyCode();
                    }
                  },
                ),

                SizedBox(height: height * 0.03),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_formatTime(_remainingSeconds)} 남음',
                      style: TextStyle(
                        fontSize: timerTextSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: _remainingSeconds > 0 && !_isResending
                          ? _resendCode
                          : null,
                      child: Text(
                        '인증번호 다시 받기',
                        style: TextStyle(
                          fontSize: timerTextSize,
                          color: _remainingSeconds > 0 && !_isResending
                              ? Colors.blue
                              : Colors.grey,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              _remainingSeconds > 0 && !_isResending
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: verticalSpacing),

                // 인증하기 버튼
                BigButton(
                  isEnabled: _codeController.text.length == 6 && !_isVerifying,
                  onTap: _codeController.text.length == 6 && !_isVerifying
                      ? _verifyCode
                      : null,
                  child: _isVerifying
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : '인증하기'.text
                            .size(buttonTextSize)
                            .color(
                              _codeController.text.length == 6
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
}
