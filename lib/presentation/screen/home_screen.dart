import 'package:daeja/features/settings/provider/theme_provider.dart';
import 'package:daeja/features/user_location/provider/user_location_provider.dart';
import 'package:daeja/presentation/widget/map/map_control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  final NaverMapController? mapController;
  final Function(NaverMapController)? onMapReady;
  final VoidCallback? onRefresh;
  final VoidCallback? onMyLocation;

  const HomeScreen({
    super.key,
    this.mapController,
    this.onMapReady,
    this.onRefresh,
    this.onMyLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocationAsync = ref.watch(userLocationProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: userLocationAsync.when(
        data: (position) => Stack(
          children: [
            // 네이버 맵
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(position.latitude, position.longitude),
                  zoom: 15,
                ),
                locationButtonEnable: false,
                mapType: isDarkMode ? NMapType.navi : NMapType.basic,
                nightModeEnable: isDarkMode,
              ),
              onMapReady: (controller) {
                onMapReady?.call(controller);
              },
            ),

            // 맵 컨트롤 버튼들
            MapControlButtons(
              mapController: mapController,
              onRefresh: onRefresh,
              onMyLocation: onMyLocation,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('위치를 불러올 수 없습니다.\n$err')),
      ),
    );
  }
}
