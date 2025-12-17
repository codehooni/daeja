import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/remote/auth_remote_datasource.dart';
import '../../../data/datasource/remote/auth_remote_datasource_firebase.dart';

// 인증 & 유저
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDatasourceFirebase();
});
