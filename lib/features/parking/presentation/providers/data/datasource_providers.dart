import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/remote/airport_api_datasource.dart';
import '../../../data/datasources/remote/jeju_api_datasource.dart';
import '../../../data/datasources/remote/private_parking_lot_datasource.dart';

// 주차장
final jejuDatasourceProvider = Provider<JejuApiDatasource>((ref) {
  return JejuApiDatasource();
});

final airportDatasourceProvider = Provider<AirportApiDatasource>((ref) {
  return AirportApiDatasource();
});

final privateDatasourceProvider = Provider<PrivateParkingLotDatasource>((ref) {
  return PrivateParkingLotDatasource();
});
