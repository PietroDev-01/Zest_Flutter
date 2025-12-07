import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/restaurant_model.dart';
import '../../controllers/restaurant_controller.dart';
import 'restaurant_details_sheet.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final RestaurantController controller = Get.find();

  RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: controller.getImageProvider(restaurant.logoUrl),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Aberto: ${restaurant.openTime} - ${restaurant.closeTime}"),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: restaurant.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              )).toList(),
            ),
          ],
        ),
        onTap: () {
          Get.bottomSheet(
            RestaurantDetailsSheet(
              restaurant: restaurant,
              isFromHome: true,
            ),
            isScrollControlled: true,
            barrierColor: Colors.black.withOpacity(0.2)
          );
        },
      ),
    );
  }
}