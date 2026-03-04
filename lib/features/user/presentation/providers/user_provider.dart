import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'domain/repository_providers.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((authUser) async {
        if (authUser != null) {
          await _loadUser(authUser);
        } else {
          state = const AsyncValue.data(null);
        }
      });
    });

    final authUser = ref.read(currentAuthUserProvider);
    if (authUser != null) {
      return await _initializeUser(authUser);
    }

    return null;
  }

  UserRepository get _userRepo => ref.read(userRepositoryProvider);

  Future<User?> _initializeUser(authUser) async {
    try {
      await _userRepo.createUser(authUser);
      final user = await _userRepo.getUser();

      if (user == null) {
        Log.e('유저 초기화 실패');
      }

      return user;
    } catch (e) {
      Log.e('유저 초기화 에러', e);
      rethrow;
    }
  }

  Future<void> _loadUser(authUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.createUser(authUser);
      return await _userRepo.getUser();
    });
  }

  Future<void> updateUser({String? name, String? phoneNumber}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.updateUser(name: name, phoneNumber: phoneNumber);
      final user = await _userRepo.getUser();
      Log.s('✅ 유저 업데이트: ${user?.name}');
      return user;
    });
  }

  /// 알림 설정 토글 (FCM 토큰 저장/삭제)
  Future<void> toggleNotifications(bool enabled) async {
    Log.d('[UserProvider] toggleNotifications 시작: $enabled');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      Log.d('[UserProvider] updateNotificationSettings 호출');
      await _userRepo.updateNotificationSettings(enabled);

      Log.d('[UserProvider] getUser 호출');
      final user = await _userRepo.getUser();

      Log.s('✅ [UserProvider] 알림 설정 변경 완료: ${enabled ? "켜짐" : "꺼짐"}');
      Log.d('[UserProvider] User 상태: notificationsEnabled=${user?.notificationsEnabled}, fcmToken=${user?.fcmToken}');

      return user;
    });
  }

  Future<void> deleteUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.deleteUser();
      Log.d('User deleted');
      return null;
    });
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.addVehicle(vehicle);
      final user = await _userRepo.getUser();
      Log.d('Vehicle added: ${vehicle.plateNumber}');
      return user;
    });
  }

  Future<void> removeVehicle(String plateNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.removeVehicle(plateNumber);
      final user = await _userRepo.getUser();
      Log.d('Vehicle removed: $plateNumber');
      return user;
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authUser = ref.read(currentAuthUserProvider);

      if (authUser == null) {
        Log.e('인증된 유저가 없음');
        return null;
      }

      await _userRepo.createUser(authUser);
      final user = await _userRepo.getUser();

      if (user == null) {
        Log.e('유저 조회 실패');
      }

      return user;
    });
  }

  Future<void> ensureUserExists(authUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.createUser(authUser);
      final user = await _userRepo.getUser();

      if (user == null) {
        Log.e('유저 생성 실패');
      } else {
        Log.s('유저 확인 완료: ${user.name}');
      }

      return user;
    });
  }
}

// 편의 Provider들
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).value;
});

final userVehiclesProvider = Provider<List<Vehicle>?>((ref) {
  return ref.watch(currentUserProvider)?.vehicles;
});
