import 'package:flutter/material.dart';

class MyBottomNavigationItem extends StatelessWidget {
  final bool isMe;
  final IconData icon;
  final VoidCallback onPressed;

  const MyBottomNavigationItem({
    super.key,
    required this.isMe,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      iconSize: isMe ? 32 : null,
      onPressed: onPressed,
    );
  }
}
