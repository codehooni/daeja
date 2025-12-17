import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/parking_lot.dart';
import 'domain/repository_providers.dart';

final parkingLotsProvider = FutureProvider<List<ParkingLot>>((ref) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return await repository.getParkingLots();
});
