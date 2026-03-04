import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // UNUserNotificationCenter delegate 설정 (포어그라운드 알림 표시를 위해 필요)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 포어그라운드에서 알림 표시 허용
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // iOS 14 이상: banner, badge, sound 모두 표시
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      // iOS 14 미만: alert, badge, sound 표시
      completionHandler([.alert, .badge, .sound])
    }
  }

  // 알림 탭 처리
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Flutter의 firebase_messaging이 처리하도록 super 호출
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}
