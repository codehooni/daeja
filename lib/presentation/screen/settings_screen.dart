import 'package:daeja/presentation/dialogs/dialogs.dart';
import 'package:daeja/presentation/theme/theme_provider.dart';
import 'package:daeja/presentation/widget/my_setting_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  String get _developerEmail => dotenv.env['DEVELOPER_EMAIL'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text('설정')),
        body: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            // 앱 설정 섹션
            _buildSectionTitle('앱 설정'),
            MySettingContainer(
              text: '테마 변경',
              item: CupertinoSwitch(
                value: context.watch<ThemeProvider>().isDarkMode,
                onChanged: (bool value) =>
                    context.read<ThemeProvider>().toggleTheme(),
                activeTrackColor: Theme.of(context).colorScheme.secondary,
              ),
            ),

            SizedBox(height: 20.0),

            // 지원
            _buildSectionTitle('지원'),
            // 문의하기
            MySettingContainer(
              text: '이메일로 문의하기',
              item: GestureDetector(
                onTap: () =>
                    Dialogs.showContactDialog(context, _developerEmail),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, size: 16),
                    SizedBox(width: 5),
                    Text('개발자 메일'),
                  ],
                ),
              ),
            ),

            // 오픈소스 라이선스
            // MySettingContainer(
            //   text: '오픈소스 라이선스',
            //   item: Icon(
            //     Icons.chevron_right,
            //     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            //   ),
            // ),
            SizedBox(height: 20.0),

            // 데이터 색션
            _buildSectionTitle('데이터'),
            MySettingContainer(
              text: '데이터 출처',
              item: Text(
                '제주 교통정보센터',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),

            SizedBox(height: 20.0),

            //
            _buildSectionTitle('앱 정보'),
            MySettingContainer(
              text: '버전',
              item: Text(
                _version,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
