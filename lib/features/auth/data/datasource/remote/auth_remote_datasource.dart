import '../../../domain/models/auth_user.dart';

abstract class AuthRemoteDataSource {
  AuthUser? get currentUser;

  Future<String> sendVerificationCode(String phoneNumber);

  Future<AuthUser> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();

  Future<void> deleteAccount();

  Stream<AuthUser?> get authStateChanges;
}
