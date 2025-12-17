import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daeja/features/user/data/datasource/remote/user_remote_datasource.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../auth/domain/models/auth_user.dart';
import '../../../domain/models/user.dart';

class UserRemoteDatasourceFirebase extends UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<User> createUser(AuthUser authUser) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(authUser.uid);

      // 이미 존재하는 경우
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        Log.d('유저가 이미 존재합니다: ${authUser.uid}');
        return User.fromJson(docSnapshot.data()!);
      }

      final newUser = User(
        uid: authUser.uid,
        phoneNumber: authUser.phoneNumber ?? '',
        createdAt: DateTime.now(),
      );

      await userDoc.set(newUser.toJson());
      Log.d('유저를 생성했습니다: ${authUser.uid}');
      return newUser;
    } catch (e) {
      Log.e('유저 생성에 실패했습니다: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      // 유저 없을 시 null 반환
      if (!doc.exists) return null;

      return User.fromJson(doc.data()!);
    } catch (e) {
      Log.e('유저 반환에 실패했습니다: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .update(user.toJson());
      Log.d('유저 정보를 업데이트 했습니다: ${user.uid}');
    } catch (e) {
      Log.e('유저 정보 업데이트에 실패했습니다: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      Log.d('유저를 삭제했습니다: $uid');
    } catch (e) {
      Log.e('유저 삭제에 실패했습니다: $e');
      rethrow;
    }
  }
}
