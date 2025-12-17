//     {
//       "id": "11111111",
//       "name": "서귀포매일올레시장",
//       "addr": "서귀포시 중앙로 62번길 18",
//       "x_crdn": 126.56326295,
//       "y_crdn": 33.25031562,
//       "park_day": "월화수목금토일",
//       "wkdy_strt": "090000",
//       "wkdy_end": "180000",
//       "lhdy_strt": "090000",
//       "lhdy_end": "180000",
//       "basic_time": 30,
//       "basic_fare": 1000,
//       "add_time": 15,
//       "add_fare": 500,
//       "whol_npls": 216
//     },

class JejuParkingInfoEntity {
  final String id;
  final String name;
  final String addr;
  final double xCrdn; // lng
  final double yCrdn; // lat
  final String parkDay;
  final String wkdyStrt;
  final String wkdyEnd;
  final String lhdyStrt;
  final String lhdyEnd;
  final int basicTime;
  final int basicFare;
  final int addTime;
  final int addFare;
  final int wholNpls;

  JejuParkingInfoEntity({
    required this.id,
    required this.name,
    required this.addr,
    required this.xCrdn,
    required this.yCrdn,
    required this.parkDay,
    required this.wkdyStrt,
    required this.wkdyEnd,
    required this.lhdyStrt,
    required this.lhdyEnd,
    required this.basicTime,
    required this.basicFare,
    required this.addTime,
    required this.addFare,
    required this.wholNpls,
  });

  factory JejuParkingInfoEntity.fromJson(Map<String, dynamic> json) {
    return JejuParkingInfoEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      addr: json['addr'] ?? '',
      xCrdn: (json['x_crdn'] ?? 0).toDouble(),
      yCrdn: (json['y_crdn'] ?? 0).toDouble(),
      parkDay: json['park_day'] ?? '',
      wkdyStrt: json['wkdy_strt'] ?? '',
      wkdyEnd: json['wkdy_end'] ?? '',
      lhdyStrt: json['lhdy_strt'] ?? '',
      lhdyEnd: json['lhdy_end'] ?? '',
      basicTime: json['basic_time'] ?? 0,
      basicFare: json['basic_fare'] ?? 0,
      addTime: json['add_time'] ?? 0,
      addFare: json['add_fare'] ?? 0,
      wholNpls: json['whol_npls'] ?? 0,
    );
  }
}
