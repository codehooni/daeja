import 'dart:convert';
import 'dart:developer';

import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/features/parking_lot/data/provider/parking_lot_provider.dart';

class ParkingLotRepository {
  Future<List<ParkingLot>?> getParkingLots() async {
    try {
      final infoRes = await ParkingLotProvider().getParkingLotInfoResponse();
      final stateRes = await ParkingLotProvider().getParkingLotStateResponse();

      if (infoRes == null || stateRes == null) {
        return null;
      }

      final infoJson = jsonDecode(infoRes);
      final stateJson = jsonDecode(stateRes);

      final List infoList = infoJson['info'];
      final List stateList = stateJson['info'];

      final stateMap = {for (var s in stateList) s['id']: s};

      List<ParkingLot> parkingLots = infoList.map((info) {
        // infoList와 stateList 병합
        final state = stateMap[info['id']] ?? {};
        final Map<String, dynamic> merged = {...info, ...state};

        return ParkingLot.fromJson(merged);
      }).toList();

      return parkingLots;
    } catch (e) {
      log('$e', name: 'ParkingLot Repository Error');
      return null;
    }
  }

  // 기본 데이터 생성 함수 - 최초 1회만 생성
  List<ParkingLot> generateInitialParkingData() {
    return [
      ParkingLot(
        id: "11111111",
        name: "서귀포매일올레시장",
        addr: "서귀포시 중앙로 62번길 18",
        xCrdn: 126.56326295,
        yCrdn: 33.25031562,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 216,
        gnrl: 204,
        lgvh: 0,
        hvvh: 0,
        emvh: 0,
        hndc: 7,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "16488201",
        name: "법원북측공영주차장",
        addr: "제주시 이도이동 1066",
        xCrdn: 126.53534209,
        yCrdn: 33.49472463,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 91,
        gnrl: 1,
        lgvh: 4,
        hvvh: 0,
        emvh: 0,
        hndc: 1,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "20019319",
        name: "산짓물공영주차장",
        addr: "제주시 건입동 1330",
        xCrdn: 126.52872778,
        yCrdn: 33.51590058,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 71,
        gnrl: 39,
        lgvh: 0,
        hvvh: 0,
        emvh: 0,
        hndc: 0,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "17680713",
        name: "이도2동공영주차장",
        addr: "제주시 오복3길 9 (이도이동 1052-2)",
        xCrdn: 126.53494394,
        yCrdn: 33.49673819,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 150,
        gnrl: 80,
        lgvh: 6,
        hvvh: 0,
        emvh: 0,
        hndc: 6,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "17759313",
        name: "북수구공영주차장",
        addr: "제주시 일도일동 1230-3",
        xCrdn: 126.52794054,
        yCrdn: 33.5146917,
        parkDay: "월화수목금토일",
        wkdyStrt: "080000",
        wkdyEnd: "220000",
        lhdyStrt: "080000",
        lhdyEnd: "220000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 51,
        gnrl: 5,
        lgvh: 0,
        hvvh: 0,
        emvh: 0,
        hndc: 3,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "17039715",
        name: "동문공설시장공영주차장",
        addr: "제주시 동문로4길 9 (일도일동 1104-2)",
        xCrdn: 126.52819953,
        yCrdn: 33.51208935,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 264,
        gnrl: 0,
        lgvh: 0,
        hvvh: 0,
        emvh: 0,
        hndc: 0,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "20251017",
        name: "동문재래시장공영주차장",
        addr: "이도1동 1330-5",
        xCrdn: 126.52608874,
        yCrdn: 33.51083484,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 95,
        gnrl: 27,
        lgvh: 5,
        hvvh: 0,
        emvh: 0,
        hndc: 6,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "17385794",
        name: "서귀중앙공영주차빌딩",
        addr: "서귀포시 중앙로 54번길 17 (서귀동 291-63)",
        xCrdn: 126.56221093,
        yCrdn: 33.2498566,
        parkDay: "월화수목금토일",
        wkdyStrt: "090000",
        wkdyEnd: "180000",
        lhdyStrt: "090000",
        lhdyEnd: "180000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 306,
        gnrl: 182,
        lgvh: 10,
        hvvh: 0,
        emvh: 0,
        hndc: 13,
        wmon: 0,
        etc: 0,
      ),
      ParkingLot(
        id: "16489518",
        name: "인제공영주차장",
        addr: "제주시 고마로 19길 5 (일도이동 409-11)",
        xCrdn: 126.54195004,
        yCrdn: 33.50479298,
        parkDay: "월화수목금토일",
        wkdyStrt: "120000",
        wkdyEnd: "210000",
        lhdyStrt: "000000",
        lhdyEnd: "000000",
        basicTime: 30,
        basicFare: 1000,
        addTime: 15,
        addFare: 500,
        wholNpls: 125,
        gnrl: 72,
        lgvh: 3,
        hvvh: 0,
        emvh: 0,
        hndc: 4,
        wmon: 0,
        etc: 0,
      ),
    ];
  }
}
