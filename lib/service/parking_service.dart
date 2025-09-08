import 'dart:convert';

import 'package:daeja/models/parking_lot.dart';
import 'package:http/http.dart' as http;

class ParkingService {
  static const String infoUrl =
      "http://api.jejuits.go.kr/api/infoParkingInfoList?code=860725";
  static const String stateUrl =
      "http://api.jejuits.go.kr/api/infoParkingStateList?code=860725";

  static Future<List<ParkingLot>> fetchParkingLots() async {
    final infoRes = await http.get(Uri.parse(infoUrl));
    final stateRes = await http.get(Uri.parse(stateUrl));

    // 호출 실패 처리
    if (infoRes.statusCode != 200 || stateRes.statusCode != 200) {
      throw Exception("API 호출 실패");
    }

    final infoJson = jsonDecode(infoRes.body);
    final stateJson = jsonDecode(stateRes.body);

    final List infoList = infoJson['info'];
    final List stateList = stateJson['info'];

    final stateMap = {for (var s in stateList) s['id']: s};

    return infoList.map((i) {
      final state = stateMap[i['id']];
      return ParkingLot.fromJson(i, state);
    }).toList();
  }
}