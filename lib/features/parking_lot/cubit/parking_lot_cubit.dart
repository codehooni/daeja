import 'package:daeja/features/parking_lot/data/model/parking_lot.dart';
import 'package:daeja/features/parking_lot/data/repository/parking_lot_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'parking_lot_state.dart';

class ParkingLotCubit extends Cubit<ParkingLotState> {
  final ParkingLotRepository parkingLotRepository;

  ParkingLotCubit(this.parkingLotRepository) : super(ParkingLotInitial());

  void fetchParkingLots() async {
    emit(ParkingLotLoading());

    final List<ParkingLot>? model = await parkingLotRepository.getParkingLots();

    emit(
      model == null
          ? ParkingLotInitial()
          : ParkingLotResult(parkingLots: model),
    );
  }
}
