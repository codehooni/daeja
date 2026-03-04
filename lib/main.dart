import 'package:daeja/core/utils/firebase_message.dart';
import 'package:daeja/daeja_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (Firebase Messaging이 의존하므로 먼저 실행)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Messaging 초기화 (Firebase 초기화 완료 후 실행)
  await FirebaseMessage().initNotifications();

  // 독립적인 작업들을 병렬로 실행하여 초기화 속도 향상
  await Future.wait([
    _initHive(),
    dotenv.load(fileName: '.env'),
  ]);

  // Naver Map은 .env 로드 후 실행 (dotenv.env 사용)
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
  );

  runApp(const ProviderScope(child: DaejaApp()));
}

/// Hive 초기화 및 Box 열기를 병렬로 처리
Future<void> _initHive() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox<String>('search_history'),
  ]);
}
