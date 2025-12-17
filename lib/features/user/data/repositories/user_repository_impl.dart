import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/car.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/remote/user_remote_datasource.dart';

class UserRepositoryImpl extends UserRepository {
  final UserRemoteDataSource _dataSource;
  User? _currentUser;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<void> createUser(AuthUser authUser) async {
    _currentUser = await _dataSource.createUser(authUser);
  }

  @override
  Future<User?> getUser() async {
    return _currentUser;
  }

  @override
  Future<void> updateUser({String? name, String? phoneNumber}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(name: name, phoneNumber: phoneNumber);

    await _dataSource.updateUser(_currentUser!);
  }

  @override
  Future<void> deleteUser() async {
    await _dataSource.deleteUser(_currentUser!.uid);
    _currentUser = null;
  }

  @override
  Future<void> addCar(Car car) async {
    if (_currentUser == null) throw Exception('로그인 된 사용자가 없습니다.');

    final cars = List<Car>.from(_currentUser!.cars ?? []);

    // 첫 번째 차량이면 기본 차량으로 설정
    if (cars.isEmpty) {
      cars.add(car.copyWith(isDefault: true));
    } else {
      cars.add(car);
    }

    _currentUser = _currentUser!.copyWith(cars: cars);
    await _dataSource.updateUser(_currentUser!);
  }

  @override
  Future<void> removeCar(String carNumber) async {
    if (_currentUser == null) throw Exception('로그인 된 사용자가 없습니다.');

    var cars = List<Car>.from(_currentUser!.cars ?? []);
    final removedCar = cars.firstWhere((c) => c.carNumber == carNumber);
    cars.removeWhere((car) => car.carNumber == carNumber);

    // 삭제된 차량이 기본 차량이었다면 첫 번째 차량을 기본으로 설정
    if (removedCar.isDefault && cars.isNotEmpty) {
      cars[0] = cars[0].copyWith(isDefault: true);
    }

    _currentUser = _currentUser!.copyWith(cars: cars);
    await _dataSource.updateUser(_currentUser!);
  }

  @override
  Future<void> setDefaultCar(String carNumber) async {
    final cars = (_currentUser!.cars ?? []).map((car) {
      return car.copyWith(isDefault: car.carNumber == carNumber);
    }).toList();

    _currentUser = _currentUser!.copyWith(cars: cars);
    await _dataSource.updateUser(_currentUser!);
  }
}
