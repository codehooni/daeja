import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  VoidCallback onPressed;

  MyFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/icons/parking-icon.png',
          color: Theme.of(context).colorScheme.onPrimary,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
