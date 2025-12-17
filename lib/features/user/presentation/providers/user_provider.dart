import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/car.dart';
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
        // 로그인 되어 있을 때
        if (authUser != null) {
          await _loadUser(authUser);
        }
        // 로그아웃 되었을 때
        else {
          state = const AsyncValue.data(null);
          Log.d('유저 생성됨');
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
      Log.d('유저를 생성했습니다: ${user?.uid}');
      return user;
    } catch (e) {
      Log.e('유저 생성에 실패했습니다: $e');
      rethrow;
    }
  }

  Future<void> _loadUser(authUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.createUser(authUser);
      final user = await _userRepo.getUser();
      Log.d('유저를 받아왔습니다: ${user?.uid}');
      return user;
    });
  }

  Future<void> updateUser({String? name, String? phoneNumber}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.updateUser(name: name, phoneNumber: phoneNumber);
      final user = await _userRepo.getUser();
      Log.d('User updated');
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

  Future<void> addCar(Car car) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.addCar(car);
      final user = await _userRepo.getUser();
      Log.d('Car added: ${car.carNumber}');
      return user;
    });
  }

  Future<void> removeCar(String carNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.removeCar(carNumber);
      final user = await _userRepo.getUser();
      Log.d('Car removed: $carNumber');
      return user;
    });
  }

  Future<void> setDefaultCar(String carNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepo.setDefaultCar(carNumber);
      final user = await _userRepo.getUser();
      Log.d('Default car set: $carNumber');
      return user;
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _userRepo.getUser();
    });
  }
}

// 편의 Provider들
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).value;
});

final userCarsProvider = Provider<List<Car>?>((ref) {
  return ref.watch(currentUserProvider)?.cars;
});

final defaultCarProvider = Provider<Car?>((ref) {
  final cars = ref.watch(userCarsProvider);
  if (cars == null || cars.isEmpty) return null;
  return cars.firstWhere((car) => car.isDefault, orElse: () => cars.first);
});
