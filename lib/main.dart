import 'package:daeja/past/feature/settings/provider/theme_provider.dart';
import 'package:daeja/past/feature/user_location/provider/user_location_provider.dart';
import 'package:daeja/past/presentation/screen/main_screen.dart';
import 'package:daeja/past/presentation/theme/dark_mode.dart';
import 'package:daeja/past/presentation/theme/light_mode.dart';
import 'package:daeja/screens/parking_map_screen.dart';
import 'package:daeja/screens/parking_test_screen.dart';
import 'package:daeja/screens/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/parking/presentation/providers/parking_providers.dart';
import 'features/user/presentation/providers/user_provider.dart';
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

  runApp(const ProviderScope(child: DataTestApp()));
}

class DataTestApp extends ConsumerStatefulWidget {
  const DataTestApp({super.key});

  @override
  ConsumerState<DataTestApp> createState() => _MyAState();
}

class _MyAState extends ConsumerState<DataTestApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('API 테스트'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Auth & User'),
              Tab(icon: Icon(Icons.local_parking), text: 'Parking List'),
              Tab(icon: Icon(Icons.map), text: 'Parking Map'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_tabController.index == 0) {
                  // Auth & User 탭: User 새로고침
                  ref.read(userProvider.notifier).refresh();
                } else if (_tabController.index == 1 ||
                    _tabController.index == 2) {
                  // Parking List/Map 탭: Parking 새로고침
                  ref.invalidate(parkingLotsProvider);
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            TestScreen(),
            ParkingTestScreen(),
            ParkingMapScreen(),
          ],
        ),
      ),
    );
  }
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
