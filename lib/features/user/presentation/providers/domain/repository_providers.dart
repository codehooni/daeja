import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';
import '../data/datasource_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userDataSourceProvider));
});
