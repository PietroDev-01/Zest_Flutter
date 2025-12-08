import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../controllers/restaurant_controller.dart';

class FilterSheet extends StatelessWidget {
  final RestaurantController controller = Get.find();
  final bool isMap;

  FilterSheet({super.key, this.isMap = false});

  final List<String> allTags = [
    "Pizzaria", "Hamburgueria", "Massas", "Comida Brasileira", 
    "Sorveteria", "Açaí", "Salgado", "Churrasco", "Bebida", 
    "Comida Caseira", "Sushi", "Lanche"
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            
            const Center(child: Text("Filtrar Restaurantes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            // 1. Switches
            Obx(() => SwitchListTile(
              title: const Text("Abertos Agora"),
              value: controller.filterOpenNow.value,
              activeColor: Colors.green,
              onChanged: (val) => controller.filterOpenNow.value = val,
            )),
            
            // Só mostra "Ordenar por Proximidade" se não estiver no mapa
            if (!isMap)
              Obx(() => SwitchListTile(
                title: const Text("Ordenar por Proximidade"),
                subtitle: const Text("Requer GPS ligado"),
                value: controller.sortByDistance.value,
                activeColor: Colors.blue,
                onChanged: (val) => controller.sortByDistance.value = val,
              )),

            const Divider(),
            const Text("Por Categoria:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 2. Tags
            Obx(() => Wrap(
              spacing: 8,
              children: allTags.map((tag) {
                final isSelected = controller.activeTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: Colors.orange[200],
                  onSelected: (bool selected) {
                    controller.toggleFilterTag(tag);
                  },
                );
              }).toList(),
            )),

            const SizedBox(height: 25),

            // 3. Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Limpar Filtros"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Salvar"),
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