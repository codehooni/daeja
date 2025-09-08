import 'package:flutter/material.dart';
import 'package:daeja/models/parking_lot.dart';
import 'package:daeja/service/parking_service.dart';

class ParkingProvider with ChangeNotifier {
  List<ParkingLot> _parkingLots = [];
  bool _isLoading = false;
  String? _error;

  List<ParkingLot> get parkingLots => _parkingLots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 주차장 데이터 가져오기
  Future<void> fetchParkingLots() async {
    if (_parkingLots.isNotEmpty) return; // 이미 로드된 경우 스킵

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _parkingLots = await ParkingService.fetchParkingLots();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _parkingLots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 데이터 새로고침
  Future<void> refreshParkingLots() async {
    _parkingLots.clear();
    await fetchParkingLots();
  }
}