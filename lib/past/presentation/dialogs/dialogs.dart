import 'package:daeja/past/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Dialogs {
  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  static void showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  static void showSettingsDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: Text(
              '설정으로 이동',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  static void showContactDialog(BuildContext context, String developerEmail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '개발자에게 문의하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('궁금한 점이나 개선 사항이 있으시면\n언제든 연락주세요! 📧'),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 10.0),
                  // 개발자 이메일
                  Expanded(
                    child: Text(
                      developerEmail,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
          TextButton(
            onPressed: () =>
                EmailUtils.copyEmailToClipboard(context, developerEmail),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 16),
                SizedBox(width: 5),
                Text('복사'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              EmailUtils.openEmailApp(context, developerEmail);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, size: 16),
                SizedBox(width: 5),
                Text('메일 앱 열기'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
