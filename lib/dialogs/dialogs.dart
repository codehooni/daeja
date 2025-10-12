import 'package:daeja/ceyhun/my_text_extension.dart';
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
        title: title.text.bold.make(),
        content: content.text.make(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: '확인'.text.make(),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: '설정으로 이동'.text.bold.make(),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: '오류'.text.bold.make(),
        content: message.text.make(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: '확인'.text.make(),
          ),
        ],
      ),
    );
  }
}
