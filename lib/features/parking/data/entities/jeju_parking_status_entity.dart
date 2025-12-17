//    {
//       "id": "11111111",
//       "gnrl": 204,
//       "lgvh": 0,
//       "hvvh": 0,
//       "emvh": 0,
//       "hndc": 7,
//       "wmon": 0,
//       "etc": 0
//     },

class JejuParkingStatusEntity {
  final String id;
  final int gnrl; // 일반 남은 면수
  final int lgvh;
  final int hvvh;
  final int emvh;
  final int hndc;
  final int wmon;
  final int etc;

  JejuParkingStatusEntity({
    required this.id,
    required this.gnrl,
    required this.lgvh,
    required this.hvvh,
    required this.emvh,
    required this.hndc,
    required this.wmon,
    required this.etc,
  });

  factory JejuParkingStatusEntity.fromJson(Map<String, dynamic> json) {
    return JejuParkingStatusEntity(
      id: json['id'] ?? '',
      gnrl: json['gnrl'] ?? 0,
      lgvh: json['lgvh'] ?? 0,
      hvvh: json['hvvh'] ?? 0,
      emvh: json['emvh'] ?? 0,
      hndc: json['hndc'] ?? 0,
      wmon: json['wmon'] ?? 0,
      etc: json['etc'] ?? 0,
    );
  }
}
