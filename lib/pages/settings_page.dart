import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/ceyhun/padding.dart';
import 'package:daeja/ceyhun/tap.dart';
import 'package:daeja/widgets/my_setting_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _developerEmail = 'jihooni0113@gmail.com';
  static const String _githubRepo = 'https://github.com/ijihun1113/daeja';

  // 이메일 복사 및 메일 앱 열기 다이얼로그
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: '개발자에게 문의하기'.text.bold.make(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            '궁금한 점이나 개선 사항이 있으시면\n언제든 연락주세요! 📧'.text.make(),
            height10,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  width10,
                  Expanded(
                    child: _developerEmail.text
                        .color(Theme.of(context).colorScheme.primary)
                        .bold
                        .make(),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: '닫기'.text.make(),
          ),
          TextButton(
            onPressed: () {
              _copyEmailToClipboard(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy, size: 16),
                width5,
                '복사'.text.make(),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _openEmailApp();
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_in_new, size: 16),
                width5,
                '메일 앱 열기'.text.make(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이메일 주소 클립보드에 복사
  void _copyEmailToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _developerEmail));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: '이메일 주소가 복사되었습니다! 📋'.text.color(Colors.white).make(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // 이메일 앱 열기
  Future<void> _openEmailApp() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: _developerEmail,
      query:
          'subject=${Uri.encodeComponent('대제주 앱 문의')}&body=${Uri.encodeComponent('안녕하세요!\n\n문의 내용:\n\n\n---\n앱 버전: v1.0.0\n기기 정보: ${Theme.of(context).platform}')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('기본 메일 앱을 찾을 수 없습니다. 이메일 주소를 복사해서 사용해주세요.');
      }
    } catch (e) {
      _showErrorSnackBar('메일 앱을 열 수 없습니다.');
    }
  }

  // GitHub 이슈 페이지 열기
  Future<void> _openGitHub() async {
    final githubUri = Uri.parse('$_githubRepo/issues');

    try {
      if (await canLaunchUrl(githubUri)) {
        await launchUrl(githubUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('브라우저를 열 수 없습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('GitHub 페이지를 열 수 없습니다.');
    }
  }


  // 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: message.text.color(Colors.white).make(),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: '설정'.text.make()),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 설정
            '앱 설정'.text.size(18.0).bold.make().p(l: 16.0),
            MySettingContainer(
              text: '테마 변경',
              item: CupertinoSwitch(
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (bool value) {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
                activeTrackColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            height20,

            // 문의 및 지원
            '문의 및 지원'.text.size(18.0).bold.make().p(l: 16.0),

            // 이메일 문의
            MySettingContainer(
              text: '이메일로 문의하기',
              item: Tap(
                onTap: () => _showContactDialog(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    width5,
                    '개발자 메일'.text
                        .color(Theme.of(context).colorScheme.onPrimaryContainer)
                        .make(),
                  ],
                ),
              ),
            ),

            // 깃허브 이슈
            MySettingContainer(
              text: '버그 신고 / 기능 제안',
              item: Tap(
                onTap: () => _openGitHub(),
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    width5,
                    'GitHub 이슈'.text
                        .color(Theme.of(context).colorScheme.onPrimaryContainer)
                        .make(),
                  ],
                ),
              ),
            ),

            // 앱 정보
            height10,
            '앱 정보'.text.size(18.0).bold.make().p(l: 16.0),
            MySettingContainer(
              text: '버전 정보',
              item: Row(
                children: [
                  'v1.0.2'.text
                      .color(
                        Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      )
                      .make(),
                  width5,
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
