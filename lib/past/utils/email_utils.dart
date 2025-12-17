import 'package:daeja/past/presentation/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailUtils {
  // 이메일 주소 클립보드에 복사
  static void copyEmailToClipboard(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));
    Navigator.pop(context);

    Dialogs.showSnackBar(
      context,
      '이메일 주소가 복사되었습니다! 📋',
      Theme.of(context).colorScheme.primary,
    );
  }

  // 이메일 앱 열기
  static Future<void> openEmailApp(BuildContext context, String email) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent('대자 앱문의')}&body=${Uri.encodeComponent('안녕하세요!\n\n문의내용:\n\n')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Dialogs.showSnackBar(
          context,
          '기본 메일 앱을 찾을 수 없습니다. 이메일 주소를 복사해서 사용해주세요.',
          Theme.of(context).colorScheme.primary,
        );
      }
    } catch (e) {
      Dialogs.showErrorDialog(context, '메일 앱을 열 수 없습니다.');
    }
  }
}
