// {aprEng: JEJU INTERNATIONAL AIRPORT,
// aprKor: 제주국제공항,
// parkingAirportCodeName: P1주차장,
// parkingFullSpace: 1763,
// parkingGetdate: 2025-12-11,
// parkingGettime: 11:13:02,
// parkingIincnt: 2018,
// parkingIoutcnt: 983,
// parkingIstay: 1763}

class AirportParkingEntity {
  final String aprKor;
  final String parkingAirportCodeName;
  final int parkingFullSpace;
  final String parkingGetdate;
  final String parkingGettime;
  final int parkingIstay;

  AirportParkingEntity({
    required this.aprKor,
    required this.parkingAirportCodeName,
    required this.parkingFullSpace,
    required this.parkingGetdate,
    required this.parkingGettime,
    required this.parkingIstay,
  });

  factory AirportParkingEntity.fromJson(Map<String, dynamic> json) {
    return AirportParkingEntity(
      aprKor: json['aprKor'] ?? '',
      parkingAirportCodeName: json['parkingAirportCodeName'] ?? '',
      parkingFullSpace: json['parkingFullSpace'] ?? '',
      parkingGetdate: json['parkingGetdate'] ?? '',
      parkingGettime: json['parkingGettime'] ?? '',
      parkingIstay: json['parkingIstay'] ?? '',
    );
  }
}
