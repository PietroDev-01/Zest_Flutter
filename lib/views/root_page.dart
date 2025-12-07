import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home/home_page.dart';
import 'map/map_page.dart';
import 'profile/profile_page.dart';

class RootPage extends StatelessWidget {
  final NavigationController navCtrl = Get.put(NavigationController());

  final List<Widget> _pages = [
    HomePage(),
    MapPage(),
    ProfilePage(), 
  ];

  RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navCtrl.selectedIndex.value,
        children: _pages,
      )),
      
      // O Menu Inferior Fixo
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: navCtrl.selectedIndex.value,
        onTap: (index) {
          navCtrl.changePage(index);
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Restaurantes"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      )),
    );
  }
}