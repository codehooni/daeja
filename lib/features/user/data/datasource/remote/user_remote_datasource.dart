import '../../../../auth/domain/models/auth_user.dart';
import '../../../domain/models/user.dart';

abstract class UserRemoteDataSource {
  Future<User> createUser(AuthUser authUser);

  Future<User?> getUser(String uid);

  Future<void> updateUser(User user);

  Future<void> deleteUser(String uid);
}
