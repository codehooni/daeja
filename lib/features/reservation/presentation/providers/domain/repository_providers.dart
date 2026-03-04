import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/user_reservation_repository_impl.dart';
import '../../../domain/repositories/user_reservation_repository.dart';
import '../data/datasource_providers.dart';

/// User Reservation Repository Provider
final userReservationRepositoryProvider = Provider<UserReservationRepository>((ref) {
  return UserReservationRepositoryImpl(
    ref.watch(userReservationDatasourceProvider),
  );
});
