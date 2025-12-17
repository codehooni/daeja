import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/distance_service.dart';

final distanceServiceProvider = Provider<DistanceService>((ref) {
  return DistanceService();
});
