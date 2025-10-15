import 'package:daeja/dialogs/dialogs.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LaunchMapHelper {
  // 네비게이션 실행 (현위치 → 목적지)
  static Future<void> launchNavigation({
    required BuildContext context,
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationTitle,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    // 네이버, 티맵, 카카오만 필터링
    final filteredMaps = availableMaps.where((map) {
      return map.mapType == MapType.naver ||
          map.mapType == MapType.tmap ||
          map.mapType == MapType.kakao;
    }).toList();

    if (filteredMaps.isEmpty) {
      if (context.mounted) {
        Dialogs.showErrorDialog(context, '네이버맵, 티맵, 카카오맵 중 하나를 설치해주세요');
      }
      return;
    }

    // 1개만 설치되어 있으면 바로 실행
    if (filteredMaps.length == 1) {
      await filteredMaps.first.showDirections(
        destination: Coords(destinationLatitude, destinationLongitude),
        destinationTitle: destinationTitle,
        origin: Coords(originLatitude, originLongitude),
        directionsMode: DirectionsMode.driving,
      );
      return;
    }

    // 여러 개 설치되어 있으면 선택 다이얼로그 표시
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(
            top: 4,
            left: 16,
            right: 16,
            bottom: 48,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 5,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              // 제목
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '지도 앱 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              // 지도 앱 목록
              ...filteredMaps.map((map) {
                String iconPath = '';
                if (map.mapType == MapType.naver) {
                  iconPath = 'assets/images/naver.svg';
                } else if (map.mapType == MapType.kakao) {
                  iconPath = 'assets/images/kakao.svg';
                } else if (map.mapType == MapType.tmap) {
                  iconPath = 'assets/images/tmap.svg';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await map.showDirections(
                          destination: Coords(
                            destinationLatitude,
                            destinationLongitude,
                          ),
                          destinationTitle: destinationTitle,
                          origin: Coords(originLatitude, originLongitude),
                          directionsMode: DirectionsMode.driving,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (iconPath.isNotEmpty)
                              SvgPicture.asset(iconPath, width: 32, height: 32)
                            else
                              Icon(
                                Icons.map,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                map.mapName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
