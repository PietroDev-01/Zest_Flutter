import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils.dart';

class RestaurantController extends GetxController {
  var restaurants = <RestaurantModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }

  // --- ABRIR ROTA NO GOOGLE MAPS EXTERNO ---
  Future<void> openRouteOnGoogleMaps(double lat, double long) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$long");
    
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Erro", "Não foi possível abrir o mapa.");
    }
  }

  // --- BUSCAR DADOS (READ) ---
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

  // --- CRIAR (CREATE) ---
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    showLoadingDialog("Cadastrando seu restaurante...");
    
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .add(restaurant.toMap());
          
      hideLoadingDialog();

      Get.offAllNamed('/home');
      
      Get.snackbar(
        "Sucesso", 
        "Restaurante cadastrado!", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 2)
      );
      
    } catch (e) {
      hideLoadingDialog();
      
      Get.snackbar(
        "Erro", 
        "Falha ao salvar: $e", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    }
  }

  // Função auxiliar de Imagem
  ImageProvider getImageProvider(String logoString) {
    if (logoString.isEmpty) {
      return const NetworkImage('https://placehold.co/100x100.png?text=Sem+Logo'); 
    }
    try {
      return MemoryImage(base64Decode(logoString));
    } catch (e) {
      return const NetworkImage('https://placehold.co/100x100.png?text=Erro');
    }
  }
}