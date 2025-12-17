import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/utils/logger.dart';

/// 해당 데이터스토어도 마찬가지로 Firebase에서 주차장 정보를 저장된 그대로 가져오게 된다.
/// 이 데이터는 User와 같은 다른 데이터에는 관심이 없고 오로지 '민영 주차장'을 위한 데이터소스이다.
class PrivateParkingLotDatasource {
  final firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchParkingLots() async {
    try {
      Log.api('민영 주차장 데이터 요청 시작');

      final snapshot = await firestore.collection('parkingLots').get();

      final results = snapshot.docs.map((doc) => doc.data()).toList();

      Log.s('Firebase 민영 주차장 ${results.length}개 로드 완료');

      return results;
    } catch (e) {
      Log.e('Firebase 민영 주차장 로드 실패', e);
      return [];
    }
  }
}
