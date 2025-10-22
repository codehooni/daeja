class ParkingLot {
  final String id;
  final String? name;
  final String? addr;
  final double? xCrdn;
  final double? yCrdn;
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

  ParkingLot({
    required this.id,
    this.name,
    this.addr,
    this.xCrdn,
    this.yCrdn,
    this.parkDay,
    this.wkdyStrt,
    this.wkdyEnd,
    this.lhdyStrt,
    this.lhdyEnd,
    this.basicTime,
    this.basicFare,
    this.addTime,
    this.addFare,
    this.wholNpls,
    this.gnrl,
    this.lgvh,
    this.hvvh,
    this.emvh,
    this.hndc,
    this.wmon,
    this.etc,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
      id: json['id'] as String,
      name: json['name'] as String?,
      addr: json['addr'] as String?,
      xCrdn: json['x_crdn'] as double?,
      yCrdn: json['y_crdn'] as double?,
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
    );
  }
}
