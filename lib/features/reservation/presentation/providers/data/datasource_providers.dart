import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/remote/reservation_datasource_firebase.dart';
import '../../../data/datasource/reservation_datasource.dart';

/// Reservation Datasource Provider
final reservationDatasourceProvider = Provider<ReservationDatasource>((ref) {
  return ReservationDatasourceFirebase();
});
