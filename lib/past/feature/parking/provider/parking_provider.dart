import 'dart:async';
import 'dart:developer';

import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:daeja/past/feature/parking/provider/firebase_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final parkingLotProvider =
    AsyncNotifierProvider<ParkingProvider, List<ParkingLot>>(() {
      return ParkingProvider();
    });

class ParkingProvider extends AsyncNotifier<List<ParkingLot>> {
  // Default Setting
  final String? _jejuApiKey = dotenv.env['JEJU_API_CODE'];
  final String? _airportApiKey = dotenv.env['AIRPORT_API_KEY'];

  final Dio _jejuDio = Dio(
    BaseOptions(
      baseUrl: 'http://api.jejuits.go.kr/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  final Dio _airportDio = Dio(
    BaseOptions(
      baseUrl: 'http://openapi.airport.co.kr/service/rest/AirportParking',
    ),
  );

  // UTIL ( GEOCODING )
  final String? _naverId = dotenv.env['NAVER_CLIENT_ID'];
  final String? _naverClient = dotenv.env['NAVER_CLIENT_SECRET'];

  final Dio _geoCodingDio = Dio(
    BaseOptions(
      baseUrl: 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2',
    ),
  );

  @override
  Future<List<ParkingLot>> build() async {
    ref.listen(firebaseParkingProvider, (previous, next) {
      next.whenData((firebaseData) {
        refresh();
      });
    });

    return await fetchParkingLots();
  }

  // Fetch All Data (Jeju + airport + private(firebase))
  Future<List<ParkingLot>> fetchParkingLots() async {
    final apiParkingLots = await _fetchJejuApiData();

    final List<ParkingLot> firebaseData =
        ref.read(firebaseParkingProvider).asData?.value ?? [];

    List<ParkingLot> airportParkingLots = [];
    try {
      airportParkingLots = await getAirportParkingLotState();
      print(airportParkingLots);
    } catch (e) {
      log('공항 주차장 데이터 로딩 실패, 빈 리스트로 진행: $e');
    }

    final merged = [...apiParkingLots, ...firebaseData, ...airportParkingLots];

    print(merged);

    return merged;
  }

  // Jeju Data
  Future<List<ParkingLot>> _fetchJejuApiData() async {
    final parkingInfo = await getParkingLotInfo();
    final parkingState = await getParkingLotState();

    List<ParkingLot> parkingLots = parkingInfo.map((info) {
      final ParkingLot state = parkingState.firstWhere((p) => p.id == info.id);
      final ParkingLot merged = info.copyWith(
        gnrl: state.gnrl,
        lgvh: state.lgvh,
        hvvh: state.hvvh,
        emvh: state.emvh,
        hndc: state.hndc,
        wmon: state.wmon,
        etc: state.etc,
        lastUpdated: state.lastUpdated ?? DateTime.now(),
        parkingType: 'public',
      );

      return merged;
    }).toList();

    return parkingLots;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await fetchParkingLots();
    });
  }

  // Method
  Future<List<ParkingLot>> getParkingLotInfo() async {
    try {
      final response = await _jejuDio.get(
        '/infoParkingInfoList',
        queryParameters: {'code': _jejuApiKey},
      );

      final results = response.data['info'] as List;

      return results.map((json) => ParkingLot.fromJson(json)).toList();
    } catch (e) {
      log('주차장 정보를 불러오는 중 오루 발생: $e');
      rethrow;
    }
  }

  Future<List<ParkingLot>> getParkingLotState() async {
    try {
      final response = await _jejuDio.get(
        '/infoParkingStateList',
        queryParameters: {'code': _jejuApiKey},
      );

      final results = response.data['info'] as List;

      return results.map((json) => ParkingLot.fromJson(json)).toList();
    } catch (e) {
      log('주차장 상태를 불러오는 중 오루 발생: $e');
      rethrow;
    }
  }

  Future<List<ParkingLot>> getAirportParkingLotState() async {
    final Map<String, Map<String, dynamic>> airportLocations = {
      'P1주차장': {
        'coords': [126.4934536, 33.5050521],
        'addr': '제주시 공항로 2',
      },
      'P2장기주차장': {
        'coords': [126.4905564, 33.5027973],
        'addr': '제주시 공항로 2',
      },
      '화물주차장': {
        'coords': [126.4995465, 33.5068259],
        'addr': '제주시 용담2동 2254',
      },
    };

    try {
      final response = await _airportDio.get(
        '/airportparkingRT?serviceKey=$_airportApiKey',
        queryParameters: {'schAirportCode': 'CJU', '_type': 'json'},
      );

      final results =
          response.data['response']['body']['items']['item'] as List;

      print('results: $results');

      final List<Future<ParkingLot>> futures = results.map((p) async {
        final String parkingCode = p['parkingAirportCodeName'] as String;
        final String airportName = '${p['aprKor']} $parkingCode';
        final int total = p['parkingFullSpace'] as int;
        final int remain = total - (p['parkingIstay'] as int);
        final info = airportLocations[parkingCode];
        final coords = info?['coords'] as List<double>? ?? [126.4928, 33.5066];
        final addr = info?['addr'] as String? ?? '제주시 공항로 2';

        return ParkingLot(
          id: airportName,
          name: airportName,
          addr: addr,
          wholNpls: total,
          gnrl: remain,
          xCrdn: coords[0],
          yCrdn: coords[1],
          basicTime: 30,
          basicFare: 600,
          addTime: 10,
          addFare: 200,
          parkingType: 'airport',
          lastUpdated: DateTime.now(),
        );
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      log('공항 주차장 상태를 불러오는 중 에러 발생: $e');
      rethrow;
    }
  }

  Future<List<double>> _getLocation(String query) async {
    try {
      final response = await _geoCodingDio.get(
        '/geocode',
        queryParameters: {'query': query},
        options: Options(
          headers: {
            'x-ncp-apigw-api-key-id': _naverId,
            'x-ncp-apigw-api-key': _naverClient,
            'Accept': 'application/json',
          },
        ),
      );

      print('GEO CODING 응답 : $response');

      final resultX = response.data['addresses'][0]['x'] as double;
      final resultY = response.data['addresses'][0]['y'] as double;

      return [resultX, resultY];
    } catch (e) {
      log('Geocoding 중 에러 발생: $e');
      rethrow;
    }
  }
}
