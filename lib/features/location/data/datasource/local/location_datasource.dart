import 'package:geolocator/geolocator.dart';

import '../../../../../core/utils/logger.dart';

class LocationDatasource {
  Future<Position> getCurrentPosition() async {
    try {
      // 1. 위치 서비스 활성화 확인
      Log.d('위치 서비스 활성화 확인');
      final serviceEnabled = await _isServiceEnabled();
      if (!serviceEnabled) {
        Log.e('위치 서비스가 비활성화됨');
        throw Exception('위치 서비스를 켜주세요');
      }

      // 2. 권한이 없으면 요청
      if (!await _checkPermission()) {
        Log.d('위치 권한 요청 중...');
        final granted = await _requestPermission();

        if (!granted) {
          Log.e('위치 권한 거부됨');
          throw Exception('위치 권한이 거부되었습니다');
        }
      }

      if (await _checkPermission() == LocationPermission.deniedForever) {
        Log.e('위치 권한 영구 거부됨');
        throw Exception('설정에서 위치 권한을 허용해주세요');
      }

      // 3. 위치 정보 가져오기
      Log.d('위치 정보 요청 시작');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Log.s('위치 정보 수신: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      Log.e('위치 정보 실패', e);
      rethrow;
    }
  }

  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<bool> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
