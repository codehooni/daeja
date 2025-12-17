import 'package:daeja/past/utils/time_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeBadge extends StatelessWidget {
  final DateTime lastUpdated;

  const TimeBadge({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: 5),
          Text(
            TimeFormat.lastUpdated(lastUpdated),
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
