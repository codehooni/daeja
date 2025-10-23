import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class CompassButton extends StatelessWidget {
  final NaverMapController? mapController;

  const CompassButton({super.key, this.mapController});

  Future<void> _resetOrientation() async {
    if (mapController == null) return;

    final cameraPosition = await mapController!.getCameraPosition();
    await mapController!.updateCamera(
      NCameraUpdate.withParams(
        target: cameraPosition.target,
        zoom: cameraPosition.zoom,
        bearing: 0,
        tilt: 0,
      ),
    );
  }

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
            onPressed: _resetOrientation,
            icon: Icon(
              Icons.navigation,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
