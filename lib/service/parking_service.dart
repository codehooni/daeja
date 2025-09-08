import 'dart:convert';
import 'dart:io';

import 'package:daeja/models/parking_lot.dart';
import 'package:http/http.dart' as http;

class ParkingService {
  static const String infoUrl =
      "http://api.jejuits.go.kr/api/infoParkingInfoList?code=860725";
  static const String stateUrl =
      "http://api.jejuits.go.kr/api/infoParkingStateList?code=860725";

  static Future<List<ParkingLot>> fetchParkingLots() async {
    try {
      // API 호출
      final infoRes = await http.get(Uri.parse(infoUrl));
      final stateRes = await http.get(Uri.parse(stateUrl));

      // HTTP 상태 코드 확인
      if (infoRes.statusCode != 200) {
        throw Exception("주차장 정보를 가져올 수 없습니다. (상태: ${infoRes.statusCode})");
      }
      if (stateRes.statusCode != 200) {
        throw Exception("주차장 상태를 가져올 수 없습니다. (상태: ${stateRes.statusCode})");
      }

      // JSON 파싱
      final infoJson = jsonDecode(infoRes.body);
      final stateJson = jsonDecode(stateRes.body);

      final List infoList = infoJson['info'];
      final List stateList = stateJson['info'];

      final stateMap = {for (var s in stateList) s['id']: s};

      return infoList.map((i) {
        final state = stateMap[i['id']];
        return ParkingLot.fromJson(i, state);
      }).toList();

    } on SocketException {
      // 인터넷 연결 문제
      throw Exception("인터넷 연결을 확인해주세요.");
    } on FormatException {
      // JSON 파싱 에러
      throw Exception("데이터 형식에 문제가 있습니다.");
    } catch (e) {
      // 기타 모든 에러
      throw Exception("주차장 정보를 불러오는 중 오류가 발생했습니다.");
    }
  }
}