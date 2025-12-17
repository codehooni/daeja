// {
// id: '04uXWHAYKumdrXEduvf5',
// name: '제주 주차장',
// parking_type: 'valet',
// addr: '제주특별자치도 제주시 월광로 24',
//
// // 좌표
// x_crdn: 126.4558234,
// y_crdn: 33.4933352,
//
// // 운영 시간
// park_day: '월화수목금토일',
// wkdy_strt: 040000,
// wkdy_end: 230000,
// lhdy_strt: 040000,
// lhdy_end: 230000,
//
// // 주차 대수
// whol_npls: 500,
// gnrl: 0,      // 일반
// hndc: 0,      // 장애인
// lgvh: 0,      // 대형
// hvvh: 0,      // 화물
// wmon: 0,      // 여성
//
// last_updated: Timestamp(seconds=1764318020, nanoseconds=80000000),
// }

import '../../../../core/utils/logger.dart';

class PrivateParkingEntity {
  final String id;
  final String name;
  final String addr;
  final double xCrdn; // longitude
  final double yCrdn; // latitude
  final String? parkDay; // 운영요일
  final String? wkdyStrt; // 평일 운영 시작시간
  final String? wkdyEnd; // 평일 운영 종료시간
  final String? lhdyStrt; // 주말 운영 시작시간
  final String? lhdyEnd; // 주말 운영 종료시간
  final int? basicTime; // 기본주차 시간
  final int? basicFare; // 기본주차 요금
  final int? addTime; // 추가주차 시간
  final int? addFare; // 추가주차 요금
  final int? wholNpls; // 총 주차면수
  // 주차 현황 필드
  final int? gnrl; // 일반 잔여 주차구역 개수
  final int? lgvh; // 경차 잔여 주차구역 개수
  final int? hvvh; // 대형 잔여 주차구역 개수
  final int? emvh; // 긴급차량 잔여 주차구역 개수
  final int? hndc; // 장애인 잔여 주차구역 개수
  final int? wmon; // 여성전용 잔여 주차구역 개수
  final int? etc; // 기타 잔여 주차구역 개수

  // Date
  // final DateTime? lastUpdated; // last_updated
  // 주차장 타입 (공영:public, 민영:private)
  final String? parkingType;

  PrivateParkingEntity({
    required this.id,
    required this.name,
    required this.parkingType,
    required this.addr,
    required this.xCrdn,
    required this.yCrdn,
    required this.parkDay,
    required this.wkdyStrt,
    required this.wkdyEnd,
    required this.lhdyStrt,
    required this.lhdyEnd,
    required this.wholNpls,
    required this.gnrl,
    required this.hndc,
    required this.lgvh,
    required this.hvvh,
    required this.wmon,
    this.emvh,
    this.etc,
    this.basicTime,
    this.basicFare,
    this.addTime,
    this.addFare,
    // required this.lastUpdated,
  });

  factory PrivateParkingEntity.fromJson(Map<String, dynamic> json) {
    return PrivateParkingEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      addr: json['addr'] as String,
      xCrdn: (json['x_crdn'] as num) as double,
      yCrdn: (json['y_crdn'] as num) as double,
      parkDay: json['park_day'] as String?,
      wkdyStrt: json['wkdy_strt'] as String?,
      wkdyEnd: json['wkdy_end'] as String?,
      lhdyStrt: json['lhdy_strt'] as String?,
      lhdyEnd: json['lhdy_end'] as String?,
      basicTime: json['basic_time'] as int?,
      basicFare: json['basic_fare'] as int?,
      addTime: json['add_time'] as int?,
      addFare: json['add_fare'] as int?,
      wholNpls: json['whol_npls'] as int?,
      gnrl: json['gnrl'] as int?,
      lgvh: json['lgvh'] as int?,
      hvvh: json['hvvh'] as int?,
      emvh: json['emvh'] as int?,
      hndc: json['hndc'] as int?,
      wmon: json['wmon'] as int?,
      etc: json['etc'] as int?,
      // lastUpdated: TimeFormat.parseFirebaseTimestamp(json['last_updated']),
      parkingType: json['parking_type'] as String?,
    );
  }
}
