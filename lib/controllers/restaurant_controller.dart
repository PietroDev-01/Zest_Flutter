import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantController extends GetxController {
  var restaurants = <RestaurantModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }

  // --- BUSCAR DADOS  ---
  void fetchRestaurants() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection('restaurants')
        .snapshots()
        .listen((snapshot) {
      
      var list = snapshot.docs.map((doc) {
        return RestaurantModel.fromMap(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      restaurants.value = list;
      isLoading.value = false;
    });
  }

  // Função auxiliar para saber se é URL ou Base64
  ImageProvider getImageProvider(String logoString) {
    if (logoString.isEmpty) {
      return const AssetImage('assets/placeholder.png');
    }
    if (logoString.startsWith('http')) {
      return NetworkImage(logoString); 
    }
    try {
      return MemoryImage(base64Decode(logoString));
    } catch (e) {
      return const AssetImage('assets/placeholder.png');
    }
  }

  // --- Criar Restaurante---
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    isLoading.value = true;

    try {
      await FirebaseFirestore.instance
      .collection('restaurants')
      .add(restaurant.toMap());

      Get.back();
      Get.snackbar("Sucesso", "Restaurante Cadastrado!", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Erro", "Falha ao Salvar: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}