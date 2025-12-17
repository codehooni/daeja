import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/models/user_location.dart';
import 'domain/repository_providers.dart';

final userLocationProvider1 =
    AsyncNotifierProvider<UserLocationNotifier, UserLocation>(() {
      return UserLocationNotifier();
    });

class UserLocationNotifier extends AsyncNotifier<UserLocation> {
  @override
  Future<UserLocation> build() async {
    try {
      final repository = ref.watch(locationRepositoryProvider);
      final location = await repository.getCurrentLocation();

      return location;
    } catch (e, stack) {
      Log.e('위치 로드 실패', e);
      Log.e('스택: $stack');

      // 기본 위치 반환 (제주 시청)
      return UserLocation(
        lat: 33.4996,
        lng: 126.5312,
        fetchedAt: DateTime(2025, 1, 1), // 임시
        accuracy: 0,
      );
    }
  }
}
