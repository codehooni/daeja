import 'package:daeja/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialogs.dart';

class UrlUtils {
  // Terms of Service URLs
  static const String termsOfServiceUrl =
      'https://sparkly-beijinho-fec979.netlify.app/';
  static const String privacyPolicyUrl =
      'https://inquisitive-pavlova-f56f57.netlify.app/';
  static const String customerServiceUrl =
      'https://spiced-edam-b14.notion.site/3050b863464580be9435cdcb99d649ee?source=copy_link';

  /// Opens a URL in the external browser
  /// Shows error feedback if launch fails
  static Future<void> openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Log.d('Successfully opened URL: $url');
      } else {
        Dialogs.showSnackBar(
          context,
          '링크를 열 수 없습니다. 브라우저가 설치되어 있는지 확인해주세요.',
          Colors.orange,
        );
        Log.e('Cannot launch URL: $url');
      }
    } catch (e) {
      Dialogs.showSnackBar(context, '링크를 여는 중 오류가 발생했습니다.', Colors.red);
      Log.e('Failed to launch URL: $url', e);
    }
  }
}
