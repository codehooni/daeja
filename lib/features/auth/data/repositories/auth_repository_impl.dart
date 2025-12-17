import 'package:daeja/features/auth/data/datasource/remote/auth_remote_datasource_firebase.dart';

import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _authDataSource;

  AuthRepositoryImpl([AuthRemoteDataSource? authDataSource])
    : _authDataSource = authDataSource ?? AuthRemoteDatasourceFirebase();

  @override
  Stream<AuthUser?> get authStateChanges => _authDataSource.authStateChanges;

  @override
  AuthUser? getCurrentUser() {
    return _authDataSource.currentUser;
  }

  @override
  Future<String> sendVerificationCode(String phoneNumber) async {
    return await _authDataSource.sendVerificationCode(phoneNumber);
  }

  @override
  Future<AuthUser?> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    return await _authDataSource.verifyCodeAndSignIn(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _authDataSource.deleteAccount();
  }
}
