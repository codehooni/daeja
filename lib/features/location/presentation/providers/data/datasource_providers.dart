import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/local/location_datasource.dart';

// 위치
final locationDataSourceProvider = Provider<LocationDatasource>((ref) {
  return LocationDatasource();
});
