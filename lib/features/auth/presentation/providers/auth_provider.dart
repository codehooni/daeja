import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../user/presentation/providers/user_provider.dart';
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
    try {
      // 1. Firestore 사용자 데이터 먼저 삭제
      Log.d('🗑️ Firestore 사용자 데이터 삭제 중...');
      await ref.read(userProvider.notifier).deleteUser();
      Log.s('✅ Firestore 사용자 데이터 삭제 완료');

      // 2. Firebase Auth 계정 삭제
      Log.d('🗑️ Firebase Auth 계정 삭제 중...');
      await _authRepo.deleteAccount();
      Log.s('✅ Firebase Auth 계정 삭제 완료');
    } catch (e) {
      Log.e('❌ 회원 탈퇴 실패', e);
      rethrow;
    }
  }

  AuthUser? getCurrentUser() {
    return _authRepo.getCurrentUser();
  }
}
