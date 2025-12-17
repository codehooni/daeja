import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/parking_repository_impl.dart';
import '../../../domain/repositories/parking_repository.dart';
import '../data/datasource_providers.dart';

final parkingRepositoryProvider = Provider<ParkingRepository>((ref) {
  return ParkingRepositoryImpl(
    ref.watch(jejuDatasourceProvider),
    ref.watch(airportDatasourceProvider),
    ref.watch(privateDatasourceProvider),
  );
});
