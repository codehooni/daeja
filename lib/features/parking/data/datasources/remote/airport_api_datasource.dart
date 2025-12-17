import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:daeja/core/utils/logger.dart';

/// ! 이 데이터는 Repository에서만 사용합니다.
/// 데이터 소스에서는 API호출을 담당하게 된다.
/// 반환되는 데이터 타입은 필요한 공항정보가 들어있는 Future<List<Map<String, dynamic>>> 이다.
/// 해당 데이터는 parking_repository_impl에서 제주 API와 함께 가공되어 model객체를 생성하게 된다.
class AirportApiDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://openapi.airport.co.kr/service/rest/AirportParking',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  final String? _airportApiKey = dotenv.env['AIRPORT_API_KEY'];

  Future<List<Map<String, dynamic>>> fetchParkingLots() async {
    Log.api('공항 주차장 데이터 요청 시작');

    try {
      final response = await _dio.get(
        '/airportparkingRT?serviceKey=$_airportApiKey',
        queryParameters: {/*'schAirportCode': 'CJU',*/ '_type': 'json'},
      );

      final results =
          response.data['response']['body']['items']['item'] as List;

      Log.s('공항 주차장 ${results.length}개 로드 완료');

      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      Log.e("공항 주차장을 불러오는 중 에러 발생: $e");
      return [];
    }
  }
}
