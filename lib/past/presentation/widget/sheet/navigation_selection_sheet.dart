import 'package:daeja/past/constants/constants.dart';
import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'sheet_handle_bar.dart';

class NavigationSelectionSheet extends StatelessWidget {
  final Coords coords;
  final String title;
  final List<AvailableMap> availableMaps;

  const NavigationSelectionSheet({
    super.key,
    required this.coords,
    required this.availableMaps,
    required this.title,
  });

  static Future<void> show(BuildContext context, ParkingLot parking) async {
    final availableMaps = await MapLauncher.installedMaps;
    final coords = Coords(
      double.parse(parking.yCrdn.toString()),
      double.parse(parking.xCrdn.toString()),
    );

    final title = parking.name.toString();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => NavigationSelectionSheet(
        coords: coords,
        availableMaps: availableMaps,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: sheetPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: sheetBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHandleBar(),
          _buildHeader(context),
          SizedBox(height: 10.0),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '지도 선택',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var map in availableMaps)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: borderRadius,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: borderRadius,
                  onTap: () {
                    Navigator.pop(context);

                    map.showDirections(
                      destination: coords,
                      destinationTitle: title,
                      directionsMode: DirectionsMode.driving,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(map.icon, height: 30.0, width: 30.0),
                        SizedBox(width: 16.0),
                        Text(
                          map.mapName,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
