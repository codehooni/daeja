import '../../../../auth/domain/models/auth_user.dart';
import '../../entities/user_entity.dart';

abstract class UserRemoteDataSource {
  Future<UserEntity> createUser(AuthUser authUser);

  Future<UserEntity?> getUser(String uid);

  Future<void> updateUser(UserEntity user);

  Future<void> deleteUser(String uid);
}
