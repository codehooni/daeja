import 'package:daeja/features/parking/data/entities/private_parking_entity.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/models/parking_lot.dart';
import '../../domain/repositories/parking_repository.dart';
import '../datasources/remote/airport_api_datasource.dart';
import '../datasources/remote/jeju_api_datasource.dart';
import '../datasources/remote/private_parking_lot_datasource.dart';
import '../entities/airport_parking_entity.dart';
import '../entities/jeju_parking_info_entity.dart';
import '../entities/jeju_parking_status_entity.dart';
import '../mappers/parking_mapper.dart';

/// 이 Repository는 datasource에서 받아온 주차장들을 하나로 묶어 model로 변환해주는 역할을 합니다.
/// 반환 되는 데이터들은 provider를 통해서 Widget에 보여지게 됩니다.
/// 현재는 parking을 상세정보까지 한번에 불러온다.
/// 그렇기 때문에 search와 getState와 같은 기능은 domain service에서 따로 제공한다.
class ParkingRepositoryImpl implements ParkingRepository {
  final JejuApiDatasource _jejuApi;
  final AirportApiDatasource _airportApi;
  final PrivateParkingLotDatasource _firebaseApi;

  ParkingRepositoryImpl(this._jejuApi, this._airportApi, this._firebaseApi);

  @override
  Future<List<ParkingLot>> getParkingLots() async {
    try {
      // 1. Datasource에서 날것의 Data 받아오기
      final results = await Future.wait([
        _jejuApi.fetchParkingInfoList(),
        _jejuApi.fetchParkingStateList(),
        _airportApi.fetchParkingLots(),
        _firebaseApi.fetchParkingLots(),
      ]);

      // 2. fromJson()으로 Data -> Entity 변환
      final jejuInfoEntities = results[0]
          .map((json) => JejuParkingInfoEntity.fromJson(json))
          .toList();
      final jejuStateEntities = results[1]
          .map((json) => JejuParkingStatusEntity.fromJson(json))
          .toList();
      final airportEntities = results[2]
          .map((json) => AirportParkingEntity.fromJson(json))
          .toList();
      final firebaseEntities = results[3]
          .map((json) => PrivateParkingEntity.fromJson(json))
          .toList();

      // 3. Mapper로 Entity → Model 변환
      final jejuLots = ParkingMapper.fromJejuList(
        jejuInfoEntities,
        jejuStateEntities,
      );
      final airportLots = ParkingMapper.fromAirportList(airportEntities);
      final firebaseLots = ParkingMapper.fromFirebaseList(firebaseEntities);

      int totalLots =
          jejuLots.length + airportLots.length + firebaseLots.length;
      Log.s('공항, 제주, 민영 주차장 총 $totalLots 개 Model 객체로 변환 완료');

      return [...jejuLots, ...airportLots, ...firebaseLots];
    } catch (e) {
      rethrow;
    }
  }
}
