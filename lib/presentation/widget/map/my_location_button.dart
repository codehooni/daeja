import 'dart:ui';

import 'package:flutter/material.dart';

class MyLocationButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MyLocationButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: Icon(
              Icons.my_location,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
