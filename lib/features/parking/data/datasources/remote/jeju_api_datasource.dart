import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/utils/logger.dart';

/// ! 이 데이터는 Repository에서만 사용합니다.
/// 이 데이터 소스는 제주 공영 주차장의 데이터를 불러오는 역할을 맡는다.
/// 정확한 기능은 주차장 정보를 불러오는 '/infoParkingInfoList'와 주차장 상태를 불러오는 '/infoParkingStateList'가 있다.
/// 이 데이터는 Repository에서 먼저 entity로 변환된다.
/// 그 후 Mapper를 통하여 Model로 변환 후 앱에서 사용된다.
class JejuApiDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://api.jejuits.go.kr/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  final String? _jejuApiKey = dotenv.env['JEJU_API_CODE'];

  // 이후에 서버를 돌리게 되면 아래 주석과 같은 방식으로 정보를 받아오자
  // fetchParkingLots() - 주차장목록을 불러온다.
  // fetchParkingLotDetail(id) - 해당 주차장의 상세정보를 불러온다.

  /// datasource에서는 오로지 데이터를 받아오는 역할만 맡게 된다.
  /// 데이터 가공은 오로지 repository가 담당하게 된다.
  /// 여기서 받아오는 entity는 model과 다르기 때문에 mapper로 model로 변환해준다.
  Future<List<Map<String, dynamic>>> fetchParkingInfoList() async {
    try {
      Log.api('제주 공영 주차장 정보 데이터 요청 시작');

      final response = await _dio.get(
        '/infoParkingInfoList',
        queryParameters: {'code': _jejuApiKey},
      );

      final result = response.data['info'];

      Log.s('제주 공영 주차장 정보 ${result.length}개 로드 완료');

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      Log.e("제주 공영 주차장 정보를 불러오는 중 에러 발생: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchParkingStateList() async {
    try {
      Log.api('제주 공영 주차장 상태 데이터 요청 시작');

      final response = await _dio.get(
        '/infoParkingStateList',
        queryParameters: {'code': _jejuApiKey},
      );

      final result = response.data['info'];

      Log.s('제주 공영 주차장 상태 ${result.length}개 로드 완료');

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      Log.e("제주 공영 주차장 상태를 불러오는 중 에러 발생: $e");
      return [];
    }
  }
}
