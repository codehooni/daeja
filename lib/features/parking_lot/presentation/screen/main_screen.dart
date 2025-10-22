import 'package:daeja/features/parking_lot/presentation/widget/my_bottom_navigation_item.dart';
import 'package:daeja/features/parking_lot/presentation/screen/home_screen.dart';
import 'package:daeja/features/parking_lot/presentation/screen/settings_screen.dart';
import 'package:daeja/features/parking_lot/presentation/widget/my_floating_action_button.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _hasInitialized = false;

  NaverMapController? mapController;

  List<Widget> get _screens => [
    HomeScreen(mapController: mapController, onMapReady: _onMapReady),

    const SettingsScreen(),
  ];

  // 페이지 전환 컨트롤
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onMapReady(NaverMapController controller) {
    setState(() {
      mapController = controller;
    });

    // 현재 위치로 초기 이동
    final userLocation = context.read<UserLocationProvider>();
    controller.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(userLocation.latitude, userLocation.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      // Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        // Modern Desing
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,

        // Bottom Navigation Bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyBottomNavigationItem(
              isMe: _currentIndex == 0,
              icon: Icons.home,
              onPressed: () => _onItemTapped(0),
            ),
            SizedBox(),

            MyBottomNavigationItem(
              isMe: _currentIndex == 1,
              icon: Icons.settings,
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
