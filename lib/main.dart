import 'package:daeja/pages/main_page.dart';
import 'package:daeja/providers/parking_provider.dart';
import 'package:daeja/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print("환경 변수 로드 실패: $e");
  }

  try {
    // Naver Map Init
    await FlutterNaverMap().init(
      clientId: dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
      onAuthFailed: (ex) {
        switch (ex) {
          case NQuotaExceededException(:final message):
            print("사용량 초과 (message: $message)");
            break;
          case NUnauthorizedClientException() ||
              NClientUnspecifiedException() ||
              NAnotherAuthFailedException():
            print("인증 실패: $ex");
            break;
        }
      },
    );
  } catch (e) {
    print("Naver Map 초기화 실패: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ParkingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: MainPage(),
    );
  }
}
