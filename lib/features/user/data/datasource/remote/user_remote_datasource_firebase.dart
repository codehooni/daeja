import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daeja/features/user/data/datasource/remote/user_remote_datasource.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../auth/domain/models/auth_user.dart';
import '../../entities/user_entity.dart';

class UserRemoteDatasourceFirebase extends UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<UserEntity> createUser(AuthUser authUser) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(authUser.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final existingData = docSnapshot.data();

        if (existingData == null) {
          throw Exception('문서 데이터가 null입니다');
        }

        return UserEntity.fromJson(existingData);
      }

      // Create new user
      final newUser = UserEntity(
        uid: authUser.uid,
        phone: authUser.phoneNumber ?? '',
        createdAt: DateTime.now().toIso8601String(),
      );

      await userDoc.set(newUser.toJson());
      Log.s('새 유저 생성: ${authUser.uid}');

      return newUser;
    } catch (e, stackTrace) {
      Log.e('유저 생성 실패', e);
      Log.e('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      if (!doc.exists) return null;

      return UserEntity.fromJson(doc.data()!);
    } catch (e) {
      Log.e('유저 조회 실패', e);
      return null;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .update(user.toJson());
    } catch (e, stackTrace) {
      Log.e('유저 업데이트 실패', e);
      Log.e('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      Log.e('유저 삭제 실패', e);
      rethrow;
    }
  }
}
