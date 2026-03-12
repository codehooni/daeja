import 'dart:convert';

import 'package:daeja/core/services/navigation_service.dart';
import 'package:daeja/core/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Log.d(
    '[FirebaseMessage.backgroundHandler] 백그라운드 메시지 수신: ${message.messageId}',
  );
  Log.d(
    '[FirebaseMessage.backgroundHandler] 제목: ${message.notification?.title}',
  );
  Log.d(
    '[FirebaseMessage.backgroundHandler] 내용: ${message.notification?.body}',
  );
  Log.d('[FirebaseMessage.backgroundHandler] 데이터: ${message.data}');
}

class FirebaseMessage {
  // Lazy initialization - Firebase가 초기화된 후에만 접근
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  // 로컬 알림 플러그인
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // 1. 권한 요청
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 권한 상태 로그
    Log.d(
      '[FirebaseMessage.initNotifications] 알림 권한 상태: ${settings.authorizationStatus}',
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Log.s('[FirebaseMessage.initNotifications] ✅ 알림 권한 허용됨');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Log.d('[FirebaseMessage.initNotifications] ⚠️ 알림 권한 임시 허용됨');
    } else {
      Log.e(
        '[FirebaseMessage.initNotifications] ❌ 알림 권한 거부됨: ${settings.authorizationStatus}',
      );
    }

    // 2. FCM 토큰 가져오기 (iOS 시뮬레이터는 APNS 미지원으로 스킵)
    try {
      final fCMToken = await _firebaseMessaging.getToken();
      if (fCMToken != null) {
        Log.d('[FirebaseMessage.initNotifications] ✅ FCM Token : $fCMToken');
      } else {
        Log.e('[FirebaseMessage.initNotifications] ❌ FCM 토큰을 가져올 수 없습니다');
      }
    } catch (e) {
      Log.d('[FirebaseMessage.initNotifications] FCM 토큰 조회 실패 (시뮬레이터 환경): $e');
    }

    // 3. 로컬 알림 초기화
    await _initLocalNotifications();

    // 4. 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. 포어그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. 알림 탭 핸들러 (백그라운드/종료 상태에서 알림 탭)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 7. 앱이 종료된 상태에서 알림으로 실행된 경우
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Log.d('[FirebaseMessage.initNotifications] 초기 메시지로 앱 실행됨');
      _handleMessageOpenedApp(initialMessage);
    }

    Log.d('[FirebaseMessage.initNotifications] 알림 초기화 완료');
  }

  // 로컬 알림 초기화
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'reservation_updates',
      '예약 알림',
      description: '예약 상태 변경 알림',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    Log.d('[FirebaseMessage._initLocalNotifications] 로컬 알림 초기화 완료');
  }

  // 포어그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    Log.d(
      '[FirebaseMessage._handleForegroundMessage] 포어그라운드 메시지 수신: ${message.messageId}',
    );
    Log.d(
      '[FirebaseMessage._handleForegroundMessage] 제목: ${message.notification?.title}',
    );
    Log.d(
      '[FirebaseMessage._handleForegroundMessage] 내용: ${message.notification?.body}',
    );
    Log.d('[FirebaseMessage._handleForegroundMessage] 데이터: ${message.data}');

    // 로컬 알림 표시
    _showLocalNotification(message);
  }

  // 알림 탭 처리 (백그라운드/종료 상태에서)
  void _handleMessageOpenedApp(RemoteMessage message) {
    Log.d(
      '[FirebaseMessage._handleMessageOpenedApp] 알림 탭으로 앱 열림: ${message.messageId}',
    );
    Log.d('[FirebaseMessage._handleMessageOpenedApp] 데이터: ${message.data}');

    // 예약 상태 변경 알림인 경우 예약 상세 화면으로 이동
    if (message.data['type'] == 'reservation_status_change') {
      final reservationId = message.data['reservationId'] as String?;
      if (reservationId != null) {
        Log.d(
          '[FirebaseMessage._handleMessageOpenedApp] 예약 상세로 이동: $reservationId',
        );
        NavigationService.navigateToReservationDetail(reservationId);
      }
    }
  }

  // 로컬 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    Log.d(
      '[FirebaseMessage._onNotificationTapped] 로컬 알림 탭됨: ${response.payload}',
    );

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        if (data['type'] == 'reservation_status_change') {
          final reservationId = data['reservationId'] as String?;
          if (reservationId != null) {
            Log.d(
              '[FirebaseMessage._onNotificationTapped] 예약 상세로 이동: $reservationId',
            );
            NavigationService.navigateToReservationDetail(reservationId);
          }
        }
      } catch (e) {
        Log.e('[FirebaseMessage._onNotificationTapped] Payload 파싱 실패', e);
      }
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'reservation_updates',
      '예약 알림',
      channelDescription: '예약 상태 변경 알림',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.event,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // payload를 JSON으로 직렬화
    final payloadData = jsonEncode(message.data);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '새 알림',
      message.notification?.body ?? '',
      details,
      payload: payloadData,
    );

    Log.d('[FirebaseMessage._showLocalNotification] 로컬 알림 표시 완료');
  }
}
