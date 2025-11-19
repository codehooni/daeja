import 'package:daeja/features/settings/provider/theme_provider.dart';
import 'package:daeja/presentation/screen/main_screen.dart';
import 'package:daeja/presentation/theme/dark_mode.dart';
import 'package:daeja/presentation/theme/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (for private parking lots)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // HIVE SETTINGS (for settings)
  await Hive.initFlutter();

  await Hive.openBox('settings');

  // LOAD KEYS
  await dotenv.load(fileName: '.env');

  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    mq = MediaQuery.of(context).size;
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
