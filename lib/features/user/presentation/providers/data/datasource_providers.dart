import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/remote/user_remote_datasource.dart';
import '../../../data/datasource/remote/user_remote_datasource_firebase.dart';

final userDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDatasourceFirebase();
});
