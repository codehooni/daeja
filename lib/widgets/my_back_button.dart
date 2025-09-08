import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ceyhun/tap.dart';

class MyBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const MyBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.back,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
