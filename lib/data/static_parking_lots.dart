import 'package:daeja/models/parking_lot.dart';

/// 정적 주차장 데이터
/// API 실패 시 fallback으로 사용
/// availableSpaces를 -1로 설정하여 실시간 정보가 없음을 표시
class StaticParkingLots {
  static final List<ParkingLot> parkingLots = [
    ParkingLot(
      id: '11111111',
      name: '서귀포매일올레시장',
      address: '서귀포시 중앙로 62번길 18',
      latitude: 33.25031562,
      longitude: 126.56326295,
      totalSpaces: 216,
      availableSpaces: -1, // 실시간 정보 없음
    ),
    ParkingLot(
      id: '16488201',
      name: '법원북측공영주차장',
      address: '제주시 이도이동 1066',
      latitude: 33.49472463,
      longitude: 126.53534209,
      totalSpaces: 91,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '20019319',
      name: '산짓물공영주차장',
      address: '제주시 건입동 1330',
      latitude: 33.51590058,
      longitude: 126.52872778,
      totalSpaces: 71,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '17680713',
      name: '이도2동공영주차장',
      address: '제주시 오복3길 9 (이도이동 1052-2)',
      latitude: 33.49673819,
      longitude: 126.53494394,
      totalSpaces: 150,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '17759313',
      name: '북수구공영주차장',
      address: '제주시 일도일동 1230-3',
      latitude: 33.5146917,
      longitude: 126.52794054,
      totalSpaces: 51,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '11251813',
      name: '신제주공영주차장',
      address: '제주시 연동 신대로12길',
      latitude: 33.48893829,
      longitude: 126.49106817,
      totalSpaces: 500,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '17039715',
      name: '동문공설시장공영주차장',
      address: '제주시 동문로4길 9 (일도일동 1104-2)',
      latitude: 33.51208935,
      longitude: 126.52819953,
      totalSpaces: 264,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '17385794',
      name: '서귀중앙공영주차빌딩',
      address: '서귀포시 중앙로 54번길 17 (서귀동 291-63)',
      latitude: 33.2498566,
      longitude: 126.56221093,
      totalSpaces: 306,
      availableSpaces: -1,
    ),
    ParkingLot(
      id: '16489518',
      name: '인제공영주차장',
      address: '제주시 고마로 19길 5 (일도이동 409-11)',
      latitude: 33.50479298,
      longitude: 126.54195004,
      totalSpaces: 125,
      availableSpaces: -1,
    ),
  ];
}
