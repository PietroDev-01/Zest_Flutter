import 'dart:ui'; // Para o Blur
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/restaurant_model.dart';
import '../../controllers/restaurant_controller.dart';
import '../restaurant/add_restaurant_page.dart';

class ManagementSheet extends StatelessWidget {
  final RestaurantModel restaurant;
  final RestaurantController controller = Get.find();

  ManagementSheet({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // Usando a mesma estrutura visual da Tela 2.1/5.1
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
            // 1. Cabeçalho (Barra Cinza)
            Center(
              child: Container(
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            // 2. Info Principal (Igual ao Detalhes)
            Row(
              children: [
                Hero(
                  tag: 'logo_${restaurant.id}', // Mantém a animação bonita
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
                      // Mostra horário igual nas outras telas
                      Text("${restaurant.openTime} às ${restaurant.closeTime}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // 3. Tags (Igual ao Detalhes)
            Wrap(
              spacing: 8,
              children: restaurant.tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange[50],
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            
            const SizedBox(height: 15),
            
            // 4. Descrição com Fundo Cinza (Igual ao Detalhes)
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

            // 5. BOTÕES DE AÇÃO (AQUI MUDA: EXCLUIR e EDITAR)
            Row(
              children: [
                // Botão EXCLUIR (Vermelho)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Tem certeza?",
                        middleText: "Isso apagará o restaurante para sempre.",
                        textConfirm: "Sim, Excluir",
                        textCancel: "Cancelar",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back(); // Fecha dialog
                          controller.deleteRestaurant(restaurant.id);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Excluir", style: TextStyle(color: Colors.white)),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Botão EDITAR (Amarelo/Laranja)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Fecha o modal
                      Get.to(() => AddRestaurantPage(restaurantToEdit: restaurant));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Editar", style: TextStyle(color: Colors.white)),
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