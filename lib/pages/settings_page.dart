import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:daeja/ceyhun/padding.dart';
import 'package:daeja/ceyhun/tap.dart';
import 'package:daeja/widgets/my_setting_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: 'Settings Page'.text.make()),
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

            // 기타
            '기타'.text.size(18.0).bold.make().p(l: 16.0),
            MySettingContainer(
              text: '문의 하기',
              item: Tap(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: '문의하기'.text.make(),
                      content: 'jihooni0113@gmail.com 로 문의 부탁드립니다.'.text.make(),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: '뒤로가기'.text.make(),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: '복사'.text.make(),
                        ),
                      ],
                    ),
                  );
                },
                child: '메일 복사하기'.text
                    .color(Theme.of(context).colorScheme.onPrimaryContainer)
                    .make(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
