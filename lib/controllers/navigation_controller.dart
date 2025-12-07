import 'package:get/get.dart';

class NavigationController extends GetxController {
  // 0 = Home, 1 = Mapa, 2 = Perfil
  var selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}