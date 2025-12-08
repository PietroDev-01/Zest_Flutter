import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'utils.dart';

class RestaurantController extends GetxController {
  // lista completa
  var allRestaurants = <RestaurantModel>[]; 
  
  // lista filtrada
  var displayedRestaurants = <RestaurantModel>[].obs;
  
  var isLoading = false.obs;
  var restaurantToFocus = Rxn<RestaurantModel>();

  // Variáveis de Filtro Ativas
  var currentSearch = ''.obs;
  var activeTags = <String>[].obs;
  var filterOpenNow = false.obs;
  var sortByDistance = false.obs;

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
      
      allRestaurants = snapshot.docs.map((doc) {
        return RestaurantModel.fromMap(doc.data(), doc.id);
      }).toList();

      // Ordenação padrão
      allRestaurants.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // Aplica os filtros
      applyFilters(); 
      isLoading.value = false;
    });
  }

  Future<void> applyFilters() async {
    List<RestaurantModel> temp = List.from(allRestaurants);

    // Busca por Nome
    if (currentSearch.value.isNotEmpty) {
      temp = temp.where((r) => r.name.toLowerCase().contains(currentSearch.value.toLowerCase())).toList();
    }

    // Filtragem por Tag
    if (activeTags.isNotEmpty) {
      temp = temp.where((r) => r.tags.any((tag) => activeTags.contains(tag))).toList();
    }

    // Filtragem por Restaurantes Abertos
    if (filterOpenNow.value) {
      final now = TimeOfDay.now();
      temp = temp.where((r) => _isRestaurantOpen(r.openTime, r.closeTime, now)).toList();
    }

    // Ordenação (Distância ou Alfábetica)
    if (sortByDistance.value) {
      Position? userPos = await _getUserLocation();
      if (userPos != null) {
        temp.sort((a,b) {
          double distA = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, a.latitude, a.longitude);
          double distB = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
      }
    } else {
      temp.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    displayedRestaurants.value = temp;
  }

  // --- LÓGICA DE HORÁRIO ---
  bool _isRestaurantOpen(String open, String close, TimeOfDay now) {
    try {
      if (open.isEmpty || close.isEmpty) return false;
      
      final openTime = _parseTime(open);
      final closeTime = _parseTime(close);
      
      final nowMinutes = now.hour * 60 + now.minute;
      final openMinutes = openTime.hour * 60 + openTime.minute;
      final closeMinutes = closeTime.hour * 60 + closeTime.minute;

      if (closeMinutes < openMinutes) { 
        // Caso especial: Abre 18:00 e fecha 02:00
        return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
      } else {
        // Caso normal: Abre 08:00 e fecha 18:00
        return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
      }
    } catch (e) {
      return false; // Se o horário for inválido (99:99), considera fechado
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<Position?> _getUserLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  // --- ACTIONS ---
  void search(String query) {
    currentSearch.value = query;
    applyFilters();
  }

  void toggleFilterTag(String tag) {
    if (activeTags.contains(tag)) {
      activeTags.remove(tag);
    } else {
      activeTags.add(tag);
    }
  }

  void clearFilters() {
    currentSearch.value = '';
    activeTags.clear();
    filterOpenNow.value = false;
    sortByDistance.value = false;
    applyFilters();
  }

  void goToMapAndFocus(RestaurantModel restaurant) {
    restaurantToFocus.value = restaurant;
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