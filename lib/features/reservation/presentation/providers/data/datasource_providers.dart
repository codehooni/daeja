import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/remote/user_reservation_datasource_firebase.dart';
import '../../../data/datasource/user_reservation_datasource.dart';

/// User Reservation Datasource Provider
final userReservationDatasourceProvider = Provider<UserReservationDatasource>((ref) {
  return UserReservationDatasourceFirebase();
});
