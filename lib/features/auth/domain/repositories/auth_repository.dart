import '../models/auth_user.dart';

/// 인증을 위한 레파지토리이다.
/// 이 앱에서는 핸드폰 인증을 사용해서 사용자를 확인한다.
abstract class AuthRepository {
  // 전화번호로 인증번호 전송
  Future<String> sendVerificationCode(String phoneNumber);

  // 인증번호 확인 및 로그인
  Future<AuthUser?> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  });

  AuthUser? getCurrentUser();

  Future<void> signOut();

  Future<void> deleteAccount();

  Stream<AuthUser?> get authStateChanges;
}
