import '../../../../core/services/fcm_token_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/remote/user_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class UserRepositoryImpl extends UserRepository {
  final UserRemoteDataSource _dataSource;
  User? _currentUser;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<void> createUser(AuthUser authUser) async {
    final userEntity = await _dataSource.createUser(authUser);
    _currentUser = UserMapper.toModel(userEntity);
  }

  @override
  Future<User?> getUser() async {
    if (_currentUser == null) {
      Log.e('캐시된 유저가 없음');
    }
    return _currentUser;
  }

  @override
  Future<void> updateUser({String? name, String? phoneNumber}) async {
    if (_currentUser == null) {
      Log.e('유저가 없어 업데이트 불가');
      return;
    }

    _currentUser = _currentUser!.copyWith(name: name, phone: phoneNumber);
    final userEntity = UserMapper.toEntity(_currentUser!);
    await _dataSource.updateUser(userEntity);
  }

  @override
  Future<void> deleteUser() async {
    await _dataSource.deleteUser(_currentUser!.uid);
    _currentUser = null;
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    if (_currentUser == null) throw Exception('로그인 된 사용자가 없습니다.');

    final vehicles = List<Vehicle>.from(_currentUser!.vehicles ?? []);
    vehicles.add(vehicle);

    _currentUser = _currentUser!.copyWith(vehicles: vehicles);

    final userEntity = UserMapper.toEntity(_currentUser!);
    await _dataSource.updateUser(userEntity);
  }

  @override
  Future<void> removeVehicle(String vehicleNumber) async {
    if (_currentUser == null) throw Exception('로그인 된 사용자가 없습니다.');

    final vehicles = List<Vehicle>.from(_currentUser!.vehicles ?? []);
    vehicles.removeWhere((vehicle) => vehicle.plateNumber == vehicleNumber);

    _currentUser = _currentUser!.copyWith(vehicles: vehicles);

    final userEntity = UserMapper.toEntity(_currentUser!);
    await _dataSource.updateUser(userEntity);
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {
    if (_currentUser == null) throw Exception('로그인 된 사용자가 없습니다.');

    final fcmTokenService = FCMTokenService();
    String? newFcmToken;

    if (enabled) {
      // 알림 켜기: FCM 토큰 저장
      await fcmTokenService.initializeAndSaveToken(_currentUser!.uid);
      newFcmToken = await fcmTokenService.getCurrentToken();
      Log.d('[UserRepository] 알림 켜짐 - FCM 토큰 저장 완료: $newFcmToken');
    } else {
      // 알림 끄기: FCM 토큰 삭제
      await fcmTokenService.deleteToken(_currentUser!.uid);
      newFcmToken = null;
      Log.d('[UserRepository] 알림 꺼짐 - FCM 토큰 삭제 완료 (null)');
    }

    // notificationsEnabled 상태와 fcmToken 업데이트
    _currentUser = _currentUser!.copyWith(
      notificationsEnabled: enabled,
      fcmToken: newFcmToken,
    );

    final userEntity = UserMapper.toEntity(_currentUser!);
    await _dataSource.updateUser(userEntity);

    Log.s('[UserRepository] 최종 상태 - notificationsEnabled: $enabled, fcmToken: $newFcmToken');
  }
}
