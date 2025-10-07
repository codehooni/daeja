import 'dart:convert';
import 'dart:io';

import 'package:daeja/models/parking_lot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParkingService {
  static String get _apiCode => dotenv.env['JEJU_API_CODE'] ?? '';

  static String get infoUrl =>
      "http://api.jejuits.go.kr/api/infoParkingInfoList?code=$_apiCode";
  static String get stateUrl =>
      "http://api.jejuits.go.kr/api/infoParkingStateList?code=$_apiCode";

  static Future<List<ParkingLot>> fetchParkingLots() async {
    try {
      // 병렬 API 호출 (성능 개선)
      final results = await Future.wait([
        http.get(Uri.parse(infoUrl)).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception("주차장 정보 요청 시간 초과"),
        ),
        http.get(Uri.parse(stateUrl)).timeout(
          const Duration(seconds: 10), 
          onTimeout: () => throw Exception("주차장 상태 요청 시간 초과"),
        ),
      ]);

      final infoRes = results[0];
      final stateRes = results[1];

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

    } on SocketException catch (e) {
      // 인터넷 연결 문제
      print("SocketException: $e");
      throw Exception("인터넷 연결을 확인해주세요.");
    } on FormatException catch (e) {
      // JSON 파싱 에러
      print("FormatException: $e");
      throw Exception("데이터 형식에 문제가 있습니다.");
    } catch (e, stackTrace) {
      // 기타 모든 에러
      print("Error fetching parking lots: $e");
      print("StackTrace: $stackTrace");
      print("API Code: $_apiCode");
      print("Info URL: $infoUrl");
      print("State URL: $stateUrl");
      throw Exception("주차장 정보를 불러오는 중 오류가 발생했습니다: $e");
    }
  }
}