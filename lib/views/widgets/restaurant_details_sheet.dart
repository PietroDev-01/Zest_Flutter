import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../models/restaurant_model.dart';
import '../../controllers/restaurant_controller.dart';
import '../../controllers/navigation_controller.dart';

class RestaurantDetailsSheet extends StatelessWidget {
  final RestaurantModel restaurant;
  final bool isFromHome;

  final RestaurantController controller = Get.find();
  final NavigationController navCtrl = Get.find();

  RestaurantDetailsSheet({
    super.key, 
    required this.restaurant,
    required this.isFromHome,
  });

  // Função para abrir o WhatsApp
  void _openWhatsApp() async {
    final cleanNumber = restaurant.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/55$cleanNumber");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Erro", "Não foi possível abrir o WhatsApp.");
    }
  }

  // Função ROTA EXTERNA (Google Maps App)
  void _openMapRoute() async {
    final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude},${restaurant.longitude}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Erro", "Não foi possível abrir o Mapa.");
    }
  }

  // Função VER NO MAPA (Navegação Interna)
  void _goToMapTab() {
    Get.back();
    controller.goToMapAndFocus(restaurant);
    navCtrl.changePage(1);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho
            Center(
              child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 15),
            
            // 2. Info Principal
            Row(
              children: [
                Hero(
                  tag: 'logo_${restaurant.id}',
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: controller.getImageProvider(restaurant.logoUrl),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("${restaurant.openTime} às ${restaurant.closeTime}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.grey)),
              ],
            ),
            
            const SizedBox(height: 15),
            // 3. Tags
            Wrap(
              spacing: 8,
              children: restaurant.tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange[50],
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 15),

            // 4. Descrição
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                restaurant.description.isNotEmpty ? restaurant.description : "Sem descrição.",
                style: TextStyle(color: Colors.grey[800], height: 1.5), 
              ),
            ),
            const SizedBox(height: 25),
            
            // 5. BOTÕES DE AÇÃO
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 15),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isFromHome ? _goToMapTab : _openMapRoute,
                    icon: Icon(isFromHome ? Icons.location_on : Icons.map, color: Colors.white),
                    label: Text(
                      isFromHome ? "Ver no Mapa" : "Definir Rota",
                      style: const TextStyle(color: Colors.white)
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}