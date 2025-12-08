import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/restaurant_controller.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/search_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Usamos Get.find() porque o RestaurantController já foi injetado no main.dart
  final RestaurantController resController = Get.find(); 
  final AuthController authController = Get.find();

  bool isExpanded = true;

  @override
  void initState() {
    super.initState();

    // Timer para encolher os botões após 7 segundos
    Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  void _showSearchDialog() {
    showCustomSearchDialog();
  }

  // Função para abrir Filtros
  void _showFilterSheet() {
    Get.bottomSheet(
      FilterSheet(isMap: false),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- MENU SUPERIOR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Obx(() {
                final nome = authController.currentUserName.value;
                final display = nome.isNotEmpty ? nome.split(' ')[0] : "Visitante";
                
                return Text(
                  "Olá $display",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                );
              }),
            ),
            
            // Botão Sugestão (Lâmpada)
            GestureDetector(
              onTap: () => Get.snackbar("Em breve", "Tela de sugestão"),
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Text("Sugestão", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(width: 5),
                    Icon(Icons.lightbulb, color: Colors.orange, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // LISTA DE RESTAURANTES
          Obx(() {
            if (resController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (resController.displayedRestaurants.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Nenhum restaurante encontrado.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 10, left: 16, right: 16),
              itemCount: resController.displayedRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = resController.displayedRestaurants[index];
                return RestaurantCard(restaurant: restaurant);
              },
            );
          }),

          // 2. WIDGETS FLUTUANTES
          Positioned(
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  bool isActive = resController.currentSearch.value.isNotEmpty;
                  return _buildAnimatedFab(
                    Icons.search, 
                    "Buscar", 
                    isActive ? Colors.orange : Colors.blue,
                    _showSearchDialog
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  bool isActive = resController.activeTags.isNotEmpty || resController.filterOpenNow.value || resController.sortByDistance.value;
                  return _buildAnimatedFab(
                    Icons.filter_list, 
                    "Filtrar", 
                    isActive ? Colors.orange : Colors.purple,
                    _showFilterSheet
                  );
                }),
                const SizedBox(height: 10),
                _buildAnimatedFab(Icons.add_business, "Add Rest.", Colors.black87, () => Get.toNamed('/add-restaurant')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget personalizado para os botões animados
  Widget _buildAnimatedFab(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExpanded) ...[
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ],
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }
}