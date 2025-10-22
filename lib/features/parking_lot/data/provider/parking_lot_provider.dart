import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class ParkingLotProvider {
  static String get _apiCode => dotenv.env['JEJU_API_CODE'] ?? '';

  static String get infoUrl =>
      "http://api.jejuits.go.kr/api/infoParkingInfoList?code=$_apiCode";

  static String get stateUrl =>
      "http://api.jejuits.go.kr/api/infoParkingStateList?code=$_apiCode";

  Future<String?> getParkingLotInfoResponse() async {
    try {
      final res = await get(Uri.parse(infoUrl));

      log('Success getting parking lot info', name: 'Response Success');

      return res.body;
    } catch (e) {
      log('$e', name: 'Response Error');
      return null;
    }
  }

  Future<String?> getParkingLotStateResponse() async {
    try {
      final res = await get(Uri.parse(stateUrl));

      log('Success getting parking lot state', name: 'Response Success');

      return res.body;
    } catch (e) {
      log('$e', name: 'Response Error');
      return null;
    }
  }
}
