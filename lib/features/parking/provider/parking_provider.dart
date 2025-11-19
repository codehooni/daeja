import 'dart:async';
import 'dart:developer';

import 'package:daeja/features/parking/model/parking_lot.dart';
import 'package:daeja/features/parking/provider/firebase_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final parkingLotProvider =
    AsyncNotifierProvider<ParkingProvider, List<ParkingLot>>(() {
      return ParkingProvider();
    });

class ParkingProvider extends AsyncNotifier<List<ParkingLot>> {
  // Default Setting
  final String? _apiKey = dotenv.env['JEJU_API_CODE'];

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://api.jejuits.go.kr/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
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

  // Fetch All Data (Jeju + private(firebase))
  Future<List<ParkingLot>> fetchParkingLots() async {
    final apiParkingLots = await _fetchJejuApiData();

    final List<ParkingLot> firebaseData =
        ref.read(firebaseParkingProvider).asData?.value ?? [];

    final merged = [...apiParkingLots, ...firebaseData];

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
      final response = await _dio.get(
        '/infoParkingInfoList',
        queryParameters: {'code': _apiKey},
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
      final response = await _dio.get(
        '/infoParkingStateList',
        queryParameters: {'code': _apiKey},
      );

      final results = response.data['info'] as List;

      return results.map((json) => ParkingLot.fromJson(json)).toList();
    } catch (e) {
      log('주차장 상태를 불러오는 중 오루 발생: $e');
      rethrow;
    }
  }
}
