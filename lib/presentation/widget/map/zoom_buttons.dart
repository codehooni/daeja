import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ZoomButtons extends StatelessWidget {
  final NaverMapController? mapController;

  const ZoomButtons({super.key, this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // zoom in
        ClipOval(
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
                onPressed: () =>
                    mapController?.updateCamera(NCameraUpdate.zoomIn()),
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 10.0),

        // zoom out
        ClipOval(
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
                onPressed: () =>
                    mapController?.updateCamera(NCameraUpdate.zoomOut()),
                icon: Icon(
                  Icons.remove,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
