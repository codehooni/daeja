import 'package:daeja/features/parking_lot/cubit/parking_lot_cubit.dart';
import 'package:daeja/features/parking_lot/data/repository/parking_lot_repository.dart';
import 'package:daeja/features/parking_lot/presentation/screen/main_screen.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/my_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  Bloc.observer = MyObserver();

  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final parkingLotRepo = ParkingLotRepository();

    return MultiProvider(
      providers: [
        // UserLocation Provider
        ChangeNotifierProvider(create: (context) => UserLocationProvider()),

        // Repository Provider
        RepositoryProvider(
          create: (context) => RepositoryProvider.value(value: parkingLotRepo),
        ),

        // Bloc Provider
        BlocProvider(create: (context) => ParkingLotCubit(parkingLotRepo)),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen()),
    );
  }
}
