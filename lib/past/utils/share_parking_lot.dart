import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:share_plus/share_plus.dart';

class ShareParkingLot {
  static Future<void> shareParkingInfo(ParkingLot parking) async {
    final String shareText =
        '''
  📍 ${parking.name}

  🅿️ 주차 현황
  - 전체 주차면: ${parking.wholNpls ?? '정보 없음'}면
  - 잔여 주차면: ${parking.gnrl ?? '정보 없음'}면

  📌 주소
  ${parking.addr ?? '주소 정보 없음'}

  🗺️ 위치 보기
  https://www.google.com/maps/search/?api=1&query=${parking.yCrdn}
  ,${parking.xCrdn}

  💰 요금 정보
  - 기본 요금: ${parking.basicFare ?? '정보 없음'}원 
  (${parking.basicTime ?? '정보 없음'}분)
  - 추가 요금: ${parking.addFare ?? '정보 없음'}원 
  (${parking.addTime ?? '정보 없음'}분)

  ⏰ 운영 시간
  - 평일: ${parking.wkdyStrt ?? '정보 없음'} ~ ${parking.wkdyEnd ?? '정보 없음'}
  - 주말: ${parking.lhdyStrt ?? '정보 없음'} ~ ${parking.lhdyEnd ?? '정보 없음'}

  대자 앱에서 공유됨
  ''';

    await Share.share(shareText);
  }
}
