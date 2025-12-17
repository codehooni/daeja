import 'dart:async';

import '../../../../../core/utils/logger.dart';
import '../../../domain/models/auth_user.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceFake extends AuthRemoteDataSource {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  static const _fakeVerificationId = 'fake-verification-id';

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<String> sendVerificationCode(String phoneNumber) async {
    Log.d('[Fake] 인증번호 전송: $phoneNumber');
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeVerificationId;
  }

  @override
  Future<AuthUser> verifyCodeAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    if (verificationId != _fakeVerificationId) {
      throw Exception('잘못된 verificationId');
    }
    if (smsCode != '123456') {
      throw Exception('잘못된 인증번호');
    }

    _currentUser = AuthUser(
      uid: 'fake-uid-${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: '+82 10-1234-5678',
    );
    _controller.add(_currentUser);

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  void dispose() => _controller.close();
}
