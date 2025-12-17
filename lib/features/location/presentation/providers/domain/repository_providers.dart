import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/location_repository_impl.dart';
import '../../../domain/repositories/location_repository.dart';
import '../data/datasource_providers.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.watch(locationDataSourceProvider));
});
