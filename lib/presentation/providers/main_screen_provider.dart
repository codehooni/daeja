import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MainScreen의 현재 탭 인덱스를 관리하는 Provider
final mainScreenTabIndexProvider = NotifierProvider<MainScreenTabNotifier, int>(
  () => MainScreenTabNotifier(),
);

class MainScreenTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}
