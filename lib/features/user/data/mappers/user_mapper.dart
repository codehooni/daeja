import '../../domain/models/user.dart';
import '../../domain/models/vehicle.dart';
import '../entities/user_entity.dart';
import '../entities/vehicle_entity.dart';

class UserMapper {
  // Entity -> Domain Model
  static User toModel(UserEntity entity) {
    return User(
      uid: entity.uid,
      phone: entity.phone,
      name: entity.name,
      vehicles: entity.vehicles?.map((v) => _vehicleToModel(v)).toList(),
      createdAt: entity.createdAt != null ? DateTime.parse(entity.createdAt!) : null,
      notificationsEnabled: entity.notificationsEnabled,
    );
  }

  // Domain Model -> Entity
  static UserEntity toEntity(User model) {
    return UserEntity(
      uid: model.uid,
      phone: model.phone,
      name: model.name,
      vehicles: model.vehicles?.map((v) => _vehicleToEntity(v)).toList(),
      createdAt: model.createdAt?.toIso8601String(),
      notificationsEnabled: model.notificationsEnabled,
    );
  }

  // VehicleEntity -> Vehicle
  static Vehicle _vehicleToModel(VehicleEntity entity) {
    return Vehicle(
      id: entity.id,
      plateNumber: entity.plateNumber,
      manufacturer: entity.manufacturer,
      model: entity.model,
      color: entity.color,
      nickName: entity.nickName,
      type: VehicleType.values.byName(entity.type),
    );
  }

  // Vehicle -> VehicleEntity
  static VehicleEntity _vehicleToEntity(Vehicle model) {
    return VehicleEntity(
      id: model.id,
      plateNumber: model.plateNumber,
      manufacturer: model.manufacturer,
      model: model.model,
      color: model.color,
      nickName: model.nickName,
      type: model.type.name,
    );
  }
}
