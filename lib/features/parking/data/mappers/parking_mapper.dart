import 'package:daeja/core/constants/airport_constants.dart';

import '../../domain/models/parking_lot.dart';
import '../entities/airport_parking_entity.dart';
import '../entities/jeju_parking_info_entity.dart';
import '../entities/jeju_parking_status_entity.dart';
import '../entities/private_parking_entity.dart';

class ParkingMapper {
  // 제주 공영주차장 리스트 변환
  static List<ParkingLot> fromJejuList(
    List<JejuParkingInfoEntity> infoList,
    List<JejuParkingStatusEntity> statusList,
  ) {
    return infoList.map((info) {
      final status = statusList.firstWhere((p) => info.id == p.id);
      return _fromJeju(info, status: status);
    }).toList();
  }

  // 제주 공영주차장 단일 변환
  static ParkingLot _fromJeju(
    JejuParkingInfoEntity info, {
    JejuParkingStatusEntity? status,
  }) {
    return ParkingLot(
      id: info.id,
      name: info.name,
      address: info.addr,
      lat: info.yCrdn,
      lng: info.xCrdn,
      totalSpots: info.wholNpls,
      availableSpots: status?.gnrl ?? 0,
      type: ParkingLotType.public,
      reservationInfo: null, // 공공 API에는 예약 안내 정보 없음
    );
  }

  // 공항 주차장 리스트
  static List<ParkingLot> fromAirportList(List<AirportParkingEntity> airports) {
    return airports.map((airport) => _fromAirport(airport)).toList();
  }

  // 공항 주차장 개별
  static ParkingLot _fromAirport(AirportParkingEntity airport) {
    final id = '${airport.aprKor}_${airport.parkingAirportCodeName}';
    final airportConstant = AirportConstants.parkingLots[id];

    return ParkingLot(
      id: id, // ID가 없기 때문에 임의로 사용
      name: "${airport.aprKor} ${airport.parkingAirportCodeName}",
      address: airportConstant!.address,
      lat: airportConstant.lat,
      lng: airportConstant.lng,
      totalSpots: airport.parkingFullSpace,
      availableSpots: airport.parkingFullSpace - airport.parkingIstay,
      type: ParkingLotType.public,
      reservationInfo: null, // 공공 API에는 예약 안내 정보 없음
    );
  }

  // 민영 주차장 리스트
  static List<ParkingLot> fromFirebaseList(
    List<PrivateParkingEntity> parkings,
  ) {
    return parkings.map((parking) => _fromFirebase(parking)).toList();
  }

  // 민영 주차장 개별
  static ParkingLot _fromFirebase(PrivateParkingEntity parking) {
    // parkingSpots 리스트의 길이로 전체 면수 계산
    final totalSpots = parking.parkingSpots.length;

    // parking_spots에서 'available' 상태인 것들만 카운트
    final availableSpots = parking.parkingSpots
        .where((spot) => spot.status == 'available')
        .length;

    // isValetSupported에 따라 타입 결정
    final type = parking.isValetSupported
        ? ParkingLotType.valet
        : ParkingLotType.private;

    return ParkingLot(
      id: parking.id,
      name: parking.name,
      address: parking.address,
      lat: parking.lat,
      lng: parking.lon,
      totalSpots: totalSpots,
      availableSpots: availableSpots,
      type: type,
      basePrice: parking.basePrice,
      unitTime: parking.unitTime,
      unitPrice: parking.unitPrice,
      reservationInfo: parking.reservationInfo, // 민영 주차장의 예약 안내 정보
      accountNumber: parking.accountNumber,
      tel: parking.tel,
    );
  }

  /// 서울시는 데이터가 이상한 것()도 많고 GEOCODING을 필요로 하기때문이 일단 보류
  // // 서울 주차장 리스트
  // static List<ParkingLot> fromSeoulList(List<SeoulParkingEntity> parkings) {
  //
  // }
  //
  // static ParkingLot _fromSeoul(SeoulParkingEntity parking) {
  //   return ParkingLot(id: parking.pkltCd, name: parking.pkltNm, address: parking.addr, lat: lat, lng: lng, totalSpots: totalSpots, availableSpots: availableSpots)
  // }
}
