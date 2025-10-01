import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(1); // 預設顯示啤酒列表頁面

  void setIndex(int index) {
    state = index;
  }

  void goToChart() {
    state = 0;
  }

  void goToBeerList() {
    state = 1;
  }

  void goToProfile() {
    state = 2;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});