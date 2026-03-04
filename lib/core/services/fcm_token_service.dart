import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daeja/core/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMTokenService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// FCM 토큰을 가져와서 Firestore에 저장
  Future<void> initializeAndSaveToken(String userId) async {
    try {
      final token = await getCurrentToken();
      if (token != null) {
        await updateTokenInFirestore(userId, token);
        Log.d('[FCMTokenService] FCM 토큰 저장 완료: $token');
      } else {
        Log.e('[FCMTokenService] FCM 토큰을 가져올 수 없습니다');
      }

      // 토큰 갱신 리스너 등록
      listenToTokenRefresh(userId);
    } catch (e) {
      Log.e('[FCMTokenService] 토큰 초기화 실패', e);
    }
  }

  /// 현재 FCM 토큰 가져오기
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      Log.e('[FCMTokenService] FCM 토큰 가져오기 실패', e);
      return null;
    }
  }

  /// Firestore의 users 컬렉션에 FCM 토큰 업데이트
  Future<void> updateTokenInFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      Log.d('[FCMTokenService] Firestore에 토큰 저장 완료');
    } catch (e) {
      Log.e('[FCMTokenService] Firestore 토큰 저장 실패', e);
      rethrow;
    }
  }

  /// FCM 토큰 갱신 리스너 등록
  void listenToTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((newToken) {
      Log.d('[FCMTokenService] FCM 토큰 갱신됨: $newToken');
      updateTokenInFirestore(userId, newToken);
    });
  }

  /// FCM 토큰 삭제 (로그아웃 시 사용)
  Future<void> deleteToken(String userId) async {
    try {
      // FCM 토큰 삭제
      await _messaging.deleteToken();

      // Firestore에서도 토큰을 null로 설정
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': null,
      });

      Log.d('[FCMTokenService] FCM 토큰 삭제 완료 (null로 설정)');
    } catch (e) {
      Log.e('[FCMTokenService] FCM 토큰 삭제 실패', e);
      rethrow;
    }
  }
}
