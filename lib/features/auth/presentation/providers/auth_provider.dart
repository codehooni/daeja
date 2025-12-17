import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'domain/repository_providers.dart';

// 인증 상태
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// 현재 로그인된 사용자
final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Auth 컨트롤러
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  Future<String> sendVerificationCode(String phoneNumber) async {
    return await _authRepo.sendVerificationCode(phoneNumber);
  }

  Future<AuthUser?> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    return await _authRepo.verifyCodeAndSignIn(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  Future<void> deleteAccount() async {
    await _authRepo.deleteAccount();
  }

  AuthUser? getCurrentUser() {
    return _authRepo.getCurrentUser();
  }
}
