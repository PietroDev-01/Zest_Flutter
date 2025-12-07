import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/restaurant_controller.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RestaurantController resController = Get.put(RestaurantController());
  
  final AuthController authController = Get.find();

  bool isExpanded = true;

  @override
  void initState() {
    super.initState();

    // Timer
    Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          isExpanded = false;
        });
      }
    });
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
              child: Text(
                _getGreeting(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              ),
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
            // Se a lista estiver vazia, mostra aviso
            if (resController.restaurants.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Nenhum restaurante cadastrado ainda.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            // Se tem dados, mostra a lista
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 10, left: 16, right: 16),
              itemCount: resController.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = resController.restaurants[index];
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
                _buildAnimatedFab(Icons.search, "Buscar", Colors.blue, () => Get.snackbar("Em breve", "Busca")),
                const SizedBox(height: 10),
                _buildAnimatedFab(Icons.filter_list, "Filtrar", Colors.purple, () => Get.snackbar("Em breve", "Filtro")),
                const SizedBox(height: 10),
                _buildAnimatedFab(Icons.add_business, "Add Rest.", Colors.black87, () => Get.toNamed('/add-restaurant')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget personalizado para os botões que encolhem
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
  String _getGreeting() {
    if (authController == null) return "Olá Visitante";
    String nome = authController!.nameController.text;
    if (nome.isEmpty) return "Olá Usuário";
    return "Olá ${nome.split(' ')[0]}";
  }
}