import 'package:daeja/ceyhun/tap.dart';
import 'package:flutter/material.dart';

class MapController extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsets? margin;

  const MapController({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 35.0,
    this.backgroundColor,
    this.iconColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tap(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
