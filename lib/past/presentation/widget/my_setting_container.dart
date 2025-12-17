import 'package:flutter/material.dart';

class MySettingContainer extends StatelessWidget {
  final String text;
  final Widget item;

  const MySettingContainer({super.key, required this.text, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 18.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(fontSize: 16.0)),
          item,
        ],
      ),
    );
  }
}
