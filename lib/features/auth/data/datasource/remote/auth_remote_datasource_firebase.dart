import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/utils/logger.dart';
import '../../../domain/models/auth_user.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceFirebase extends AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user != null
        ? AuthUser(uid: user.uid, phoneNumber: user.phoneNumber)
        : null;
  }

  @override
  Future<String> sendVerificationCode(String phoneNumber) async {
    Log.d('📱 인증번호 전송 시작: $phoneNumber');
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 120),

      // Android 기기의 SMS 코드 자동 처리.
      verificationCompleted: (PhoneAuthCredential credential) async {
        Log.d('✅ SMS 자동 인증 완료');
        await _auth.signInWithCredential(credential);
      },

      // 잘못된 전화번호나 SMS 할당량 초과 여부 등의 실패 이벤트를 처리합니다.
      verificationFailed: (FirebaseAuthException e) {
        Log.e('❌ 인증 실패: ${e.code} - ${e.message}');
        completer.completeError(Exception('인증 실패: ${e.message}'));
      },

      // Firebase에서 기기로 코드가 전송된 경우를 처리하며 사용자에게 코드를 입력하라는 메시지를 표시하는 데 사용됩니다.
      codeSent: (String verificationId, int? resendToken) async {
        Log.d('📨 인증번호 전송 완료!');
        Log.d('🔑 Verification ID: ${verificationId.substring(0, 20)}...');
        Log.d('🔄 Resend Token: $resendToken');
        completer.complete(verificationId);
      },

      // 자동 SMS 코드 처리에 실패한 경우 시간 초과를 처리합니다. (기본 60초)
      codeAutoRetrievalTimeout: (String verificationId) {
        Log.d('⏱️ 자동 검색 타임아웃 (120초)');
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<AuthUser> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    Log.d('🔐 인증 코드 검증 시작');
    Log.d('🔑 Verification ID: ${verificationId.substring(0, 20)}...');
    Log.d('🔢 SMS Code: $smsCode');

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      Log.e('❌ 로그인 실패: user is null');
      throw Exception('로그인 실패');
    }

    Log.s('로그인 성공: ${user.uid}');
    return AuthUser(uid: user.uid, phoneNumber: user.phoneNumber);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다');
    }

    Log.d('🗑️ 회원 탈퇴 시작: ${user.uid}');

    try {
      // Firebase Auth 계정 삭제
      await user.delete();
      Log.s('✅ Firebase Auth 계정 삭제 완료');
    } catch (e) {
      Log.e('❌ Firebase Auth 계정 삭제 실패', e);
      rethrow;
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null
          ? AuthUser(uid: user.uid, phoneNumber: user.phoneNumber)
          : null;
    });
  }
}
