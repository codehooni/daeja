import '/core/widgets/button/big_button.dart';

import 'main_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 로그인 상태 확인 후 자동으로 MainScreen으로 이동
  Future<void> _checkLoginStatus() async {
    // 약간의 딜레이를 주어 splash 화면이 잠깐 보이도록
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 로그인되어 있으면 MainScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // 반응형 계산
    final isTablet = width > 600;
    final isLandscape = width > height;

    final imageSize = isTablet ? width * 0.4 : width * 0.5;
    final titleSize = isTablet ? 48.0 : 32.0;
    final subtitleSize = isTablet ? 24.0 : 18.0;
    final buttonTextSize = isTablet ? 24.0 : 18.0;
    final signInTextSize = isTablet ? 18.0 : 16.0;

    final horizontalPadding = width * 0.1;
    final topPadding = isLandscape ? height * 0.1 : height * 0.2;
    final bottomPadding = height * 0.1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            top: topPadding,
            right: horizontalPadding,
            bottom: bottomPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),

              // 상단 컨텐츠
              Column(
                children: [
                  // 이미지
                  Image.asset('assets/images/Ioniq-6.png', width: imageSize),

                  SizedBox(height: height * 0.03),

                  // 타이틀
                  '대자'.text.size(titleSize).bold.make(),

                  SizedBox(height: height * 0.01),

                  // 서브타이틀
                  '전국의 모든 주차장을 한 눈에!'.text
                      .size(subtitleSize)
                      .color(Colors.grey.shade500)
                      .make(),
                ],
              ),

              const Spacer(),

              // 하단 버튼들
              Column(
                children: [
                  // 시작 버튼
                  BigButton(
                    child: '시작하기'.text
                        .size(buttonTextSize)
                        .color(Colors.white)
                        .bold
                        .make(),
                    onTap: () {
                      // MainScreen으로 이동 (위치 권한은 LocationDatasource에서 처리)
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignInScreen()),
                      );
                    },
                    child: '로그인'.text
                        .size(signInTextSize)
                        .color(Colors.grey.shade600)
                        .underline
                        .make(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
