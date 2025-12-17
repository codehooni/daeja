import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daeja/past/feature/parking/model/parking_lot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseParkingProvider = StreamProvider<List<ParkingLot>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('parkingLots').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final parkingLot = ParkingLot.fromJson(data);
      return parkingLot;
    }).toList();
  });
});
