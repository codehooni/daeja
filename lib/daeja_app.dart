import 'package:daeja/core/services/fcm_token_service.dart';
import 'package:daeja/core/services/navigation_service.dart';
import 'package:daeja/core/utils/logger.dart';
import 'package:daeja/presentation/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DaejaApp extends StatefulWidget {
  const DaejaApp({super.key});

  @override
  State<DaejaApp> createState() => _DaejaAppState();
}

class _DaejaAppState extends State<DaejaApp> {
  @override
  void initState() {
    super.initState();
    _initFCMToken();
  }

  /// 로그인된 사용자의 FCM 토큰 저장
  Future<void> _initFCMToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Log.d('[DaejaApp] 로그인된 사용자 감지: ${user.uid}');
        final fcmTokenService = FCMTokenService();
        await fcmTokenService.initializeAndSaveToken(user.uid);
        Log.s('[DaejaApp] FCM 토큰 초기화 완료');
      } else {
        Log.d('[DaejaApp] 로그인된 사용자 없음');
      }
    } catch (e) {
      Log.e('[DaejaApp] FCM 토큰 초기화 실패', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
