import 'package:flutter/material.dart';
import 'package:daeja/models/parking_lot.dart';
import 'package:daeja/service/parking_service.dart';

class ParkingProvider with ChangeNotifier {
  List<ParkingLot> _parkingLots = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  List<ParkingLot> get parkingLots => _parkingLots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 캐시 유효성 확인 (3분간 유효)
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!).inMinutes < 3;
  }

  // 주차장 데이터 가져오기 (캐시 최적화)
  Future<void> fetchParkingLots({bool forceRefresh = false}) async {
    // 캐시가 유효하고 강제 새로고침이 아닌 경우 스킵
    if (!forceRefresh && _parkingLots.isNotEmpty && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _parkingLots = await ParkingService.fetchParkingLots();
      _lastFetchTime = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      // 캐시된 데이터가 있으면 유지, 없으면 빈 리스트
      if (_parkingLots.isEmpty) {
        _parkingLots = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 데이터 새로고침
  Future<void> refreshParkingLots() async {
    await fetchParkingLots(forceRefresh: true);
  }
}