import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/admin_reservation_repository_impl.dart';
import '../../../domain/repositories/admin_reservation_repository.dart';
import '../data/datasource_providers.dart';

/// Reservation Repository Provider
final reservationRepositoryProvider = Provider<AdminReservationRepository>((ref) {
  return AdminReservationRepositoryImpl(
    ref.watch(reservationDatasourceProvider),
  );
});
