import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BigButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isEnabled;

  const BigButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Center(
        child: child,
      )
          .box
          .rounded
          .size(double.infinity, 70)
          .color(isEnabled ? Colors.blue : Colors.grey.shade300)
          .make(),
    );
  }
}
