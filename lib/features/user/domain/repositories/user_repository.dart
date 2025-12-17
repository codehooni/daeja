import '../../../auth/domain/models/auth_user.dart';
import '../models/car.dart';
import '../models/user.dart';

/// 여기서는 유저의 정보를 관리한다.
abstract class UserRepository {
  Future<void> createUser(AuthUser authUser);

  Future<User?> getUser();

  Future<void> updateUser({String? name, String? phoneNumber});

  Future<void> deleteUser();

  Future<void> addCar(Car car);

  Future<void> removeCar(String carNumber);

  Future<void> setDefaultCar(String carNumber);
}
