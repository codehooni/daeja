import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/utils/logger.dart';

//http://openapi.seoul.go.kr:8088/647858505166746a37366671464f6b/json/GetParkingInfo/1/20/
/// 이 데이터는 현재 상용화할 수 있을 정도의 질이 되지 않아서 현재는 사용하지 않습니다.
/// 추후 API가 업데이트 된다면 사용을 고려해봅니다.
/// 추후 사용시 Entity는 만들어져있으니 mapper와 repository를 순서대로 만들고
/// provider로 UI에서 이용하면 됩니다.
class SeoulApiDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://openapi.seoul.go.kr:8088',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  final String? _seoulApiKey = dotenv.env['SEOUL_API_CODE'];

  Future<List<Map<String, dynamic>>> fetchParkingInfoList() async {
    try {
      Log.api('서울시 시영 주차장 데이터 요청 시작');

      final response = await _dio.get(
        '/$_seoulApiKey/json/GetParkingInfo/1/187',
      );

      final result = response.data['GetParkingInfo']['row'];

      Log.s('서울시 시영 주차장 ${result.length}개 로드 완료');

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      Log.e("서울시 시영 주차장을 불러오는 중 에러 발생: $e");
      return [];
    }
  }
}
